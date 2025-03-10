# 🚀 Airbnb London Analytics with dbt, Snowflake, AWS S3, and GitHub Actions

## 📌 Prerequisites
- **dbt Core** installed ([Installation Guide](https://docs.getdbt.com/docs/core/installation))
- **VS Code & dbt Power User Extension**
- **Snowflake** account and credentials
- **AWS S3 bucket (for storing datasets)**
- **Git & GitHub (for version control and CI/CD)**
- **Looker Studio (for dashboarding)**

## 📥 Dataset
We use the **[Airbnb London dataset](http://insideairbnb.com/get-the-data/)**, which contains listings, reviews, and calendar availability data.

### Preparing the Data:
1. Download the dataset (CSV format) from the link above.(PS: I have take the zip csv files to get more columns)
2. Store the files (`listings.csv`, `calendar.csv`, `reviews.csv`) in an AWS S3 bucket.

## ❄️ Snowflake Setup
### 🛠️ Create an S3 Bucket and Upload CSV Files
Refer to AWS documentation for configuring S3 and integrating with Snowflake.

### 🔗 Setting up AWS Integration:
```sql
USE WAREHOUSE AIRBNB_WH;

CREATE OR REPLACE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = '<YOUR_AWS_ROLE>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket/your-folder/');
```

### 🏗️ Setting Up Data in Snowflake:
```sql
USE WAREHOUSE COMPUTE_WH;
USE DATABASE AIRBNB;
USE SCHEMA RAW;

-- tables 
CREATE OR REPLACE TABLE listings (
    id INT PRIMARY KEY,
    listing_url STRING,
    scrape_id BIGINT,
    last_scraped DATE,
    source STRING,
    name STRING,
    description STRING,
    neighborhood_overview STRING,
    picture_url STRING,
    host_id INT,
    host_url STRING,
    host_name STRING,
    host_since DATE,
    host_location STRING,
    host_about STRING,
    host_response_time STRING,
    host_response_rate STRING,
    host_acceptance_rate STRING,
    host_is_superhost BOOLEAN,
    host_thumbnail_url STRING,
    host_picture_url STRING,
    host_neighbourhood STRING,
    host_listings_count INT,
    host_total_listings_count INT,
    host_verifications VARIANT,
    host_has_profile_pic BOOLEAN,
    host_identity_verified BOOLEAN,
    neighbourhood STRING,
    neighbourhood_cleansed STRING,
    neighbourhood_group_cleansed STRING,
    latitude FLOAT,
    longitude FLOAT,
    property_type STRING,
    room_type STRING,
    accommodates INT,
    bathrooms FLOAT,
    bathrooms_text STRING,
    bedrooms INT,
    beds INT,
    amenities ARRAY,
    price STRING,
    minimum_nights INT,
    maximum_nights INT,
    minimum_minimum_nights INT,
    maximum_minimum_nights INT,
    minimum_maximum_nights INT,
    maximum_maximum_nights INT,
    minimum_nights_avg_ntm FLOAT,
    maximum_nights_avg_ntm FLOAT,
    calendar_updated STRING,
    has_availability BOOLEAN,
    availability_30 INT,
    availability_60 INT,
    availability_90 INT,
    availability_365 INT,
    calendar_last_scraped DATE,
    number_of_reviews INT,
    number_of_reviews_ltm INT,
    number_of_reviews_l30d INT,
    first_review DATE,
    last_review DATE,
    review_scores_rating FLOAT,
    review_scores_accuracy FLOAT,
    review_scores_cleanliness FLOAT,
    review_scores_checkin FLOAT,
    review_scores_communication FLOAT,
    review_scores_location FLOAT,
    review_scores_value FLOAT,
    license STRING,
    instant_bookable BOOLEAN,
    calculated_host_listings_count INT,
    calculated_host_listings_count_entire_homes INT,
    calculated_host_listings_count_private_rooms INT,
    calculated_host_listings_count_shared_rooms INT,
    reviews_per_month FLOAT
);


CREATE TABLE calendar (
    listing_id INT REFERENCES listings(id),
    date DATE,
    available BOOLEAN,
    price STRING,
    adjusted_price STRING,
    minimum_nights INT,
    maximum_nights INT
);

CREATE TABLE reviews (
    listing_id INT REFERENCES listings(id),
    id INT PRIMARY KEY,
    date DATE,
    reviewer_id INT,
    reviewer_name STRING,
    comments STRING
);

```

### 📤 Creating file formats for Loading Data:
```sql

-- Create FILE FORMATS
CREATE OR REPLACE FILE FORMAT AIRBNB.FILE_FORMATS.LISTINGS_CSV
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
  DATE_FORMAT = 'YYYY-MM-DD'
  TIME_FORMAT = 'HH24:MI:SS'
  TRIM_SPACE = TRUE;

CREATE OR REPLACE FILE FORMAT AIRBNB.FILE_FORMATS.CALENDAR_CSV
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  DATE_FORMAT = 'YYYY-MM-DD';

CREATE OR REPLACE FILE FORMAT AIRBNB.FILE_FORMATS.REVIEWS_CSV
  TYPE = CSV
  FIELD_DELIMITER = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  ESCAPE_UNENCLOSED_FIELD = '\\'  -- Allows escaping special characters
  TRIM_SPACE = TRUE
  DATE_FORMAT = 'YYYY-MM-DD';

```

### 📤 Creating External Stage and Loading Data:
```sql
CREATE OR REPLACE STAGE AIRBNB.EXTERNAL_STAGES.LISTINGS
  URL = 's3://your-bucket/listingss.csv'
  STORAGE_INTEGRATION = s3_int
  FILE_FORMAT = AIRBNB.FILE_FORMATS.LISTINGS_CSV;

CREATE OR REPLACE STAGE AIRBNB.EXTERNAL_STAGES.CALENDAR
  URL = 's3://your-bucket/calendar.csv'
  STORAGE_INTEGRATION = s3_int
  FILE_FORMAT = AIRBNB.FILE_FORMATS.CALENDAR_CSV;

CREATE OR REPLACE STAGE AIRBNB.EXTERNAL_STAGES.REVIEWS
  URL = 's3://your-bucket/reviews.csv'
  STORAGE_INTEGRATION = s3_int
  FILE_FORMAT = AIRBNB.FILE_FORMATS.REVIEWS_CSV;

-- Load Data into RAW Tables
COPY INTO AIRBNB.RAW.LISTINGS
FROM (
    SELECT 
        $1::INT AS id,
        $2::STRING AS listing_url,
        $3::BIGINT AS scrape_id,
        $4::DATE AS last_scraped,
        $5::STRING AS source,
        $6::STRING AS name,
        $7::STRING AS description,
        $8::STRING AS neighborhood_overview,
        $9::STRING AS picture_url,
        $10::INT AS host_id,
        $11::STRING AS host_url,
        $12::STRING AS host_name,
        $13::DATE AS host_since,
        $14::STRING AS host_location,
        $15::STRING AS host_about,
        $16::STRING AS host_response_time,
        $17::STRING AS host_response_rate,
        $18::STRING AS host_acceptance_rate,
        $19::BOOLEAN AS host_is_superhost,
        $20::STRING AS host_thumbnail_url,
        $21::STRING AS host_picture_url,
        $22::STRING AS host_neighbourhood,
        $23::INT AS host_listings_count,
        $24::INT AS host_total_listings_count,
        CASE 
            WHEN TRY_PARSE_JSON($25) IS NOT NULL 
            THEN $25 
            ELSE '["unknown"]' 
        END AS host_verifications, -- Load JSON as STRING first
        $26::BOOLEAN AS host_has_profile_pic,
        $27::BOOLEAN AS host_identity_verified,
        $28::STRING AS neighbourhood,
        $29::STRING AS neighbourhood_cleansed,
        $30::STRING AS neighbourhood_group_cleansed,
        $31::FLOAT AS latitude,
        $32::FLOAT AS longitude,
        $33::STRING AS property_type,
        $34::STRING AS room_type,
        $35::INT AS accommodates,
        $36::FLOAT AS bathrooms,
        $37::STRING AS bathrooms_text,
        $38::INT AS bedrooms,
        $39::INT AS beds,
        $40::STRING AS amenities,  -- Load JSON as STRING first
        $41::STRING AS price,
        $42::INT AS minimum_nights,
        $43::INT AS maximum_nights,
        $44::INT AS minimum_minimum_nights,
        $45::INT AS maximum_minimum_nights,
        $46::INT AS minimum_maximum_nights,
        $47::INT AS maximum_maximum_nights,
        $48::FLOAT AS minimum_nights_avg_ntm,
        $49::FLOAT AS maximum_nights_avg_ntm,
        $50::STRING AS calendar_updated,
        $51::BOOLEAN AS has_availability,
        $52::INT AS availability_30,
        $53::INT AS availability_60,
        $54::INT AS availability_90,
        $55::INT AS availability_365,
        $56::DATE AS calendar_last_scraped,
        $57::INT AS number_of_reviews,
        $58::INT AS number_of_reviews_ltm,
        $59::INT AS number_of_reviews_l30d,
        $60::DATE AS first_review,
        $61::DATE AS last_review,
        $62::FLOAT AS review_scores_rating,
        $63::FLOAT AS review_scores_accuracy,
        $64::FLOAT AS review_scores_cleanliness,
        $65::FLOAT AS review_scores_checkin,
        $66::FLOAT AS review_scores_communication,
        $67::FLOAT AS review_scores_location,
        $68::FLOAT AS review_scores_value,
        $69::STRING AS license,
        $70::BOOLEAN AS instant_bookable,
        $71::INT AS calculated_host_listings_count,
        $72::INT AS calculated_host_listings_count_entire_homes,
        $73::INT AS calculated_host_listings_count_private_rooms,
        $74::INT AS calculated_host_listings_count_shared_rooms,
        $75::FLOAT AS reviews_per_month
    FROM @AIRBNB.EXTERNAL_STAGES.LISTINGS
    (FILE_FORMAT => AIRBNB.FILE_FORMATS.LISTINGS_CSV)
);

COPY INTO AIRBNB.RAW.CALENDAR
FROM @AIRBNB.EXTERNAL_STAGES.CALENDAR
  FILE_FORMAT = AIRBNB.FILE_FORMATS.CALENDAR_CSV;

COPY INTO AIRBNB.RAW.REVIEWS
FROM (
    SELECT 
        $1::INT AS listing_id,
        $2::INT AS id,
        $3::DATE AS date,
        $4::INT AS reviewer_id,
        $5::STRING AS reviewer_name,
        REGEXP_REPLACE($6, '<br/>', ' ')::STRING AS comments  -- Replace <br/> with space
    FROM @AIRBNB.EXTERNAL_STAGES.REVIEWS
)
FILE_FORMAT = AIRBNB.FILE_FORMATS.REVIEWS_CSV;
```

## **Configure dbt**
### **Location of profiles.yml:**
```sh
C:\Users\YourUsername\.dbt\profiles.yml
```
Edit `profiles.yml`:
```yml
dbt_assignment2:
  outputs:
    dev:
      account: your_snowflake_account
      database: your_database
      password: your_password
      role: your_role
      schema: DEV
      threads: 4
      type: snowflake
      user: your_user
      warehouse: your_warehouse
    prod:
      account: your_snowflake_account
      database: your_database
      password: your_password
      role: your_role
      schema: PROD
      threads: 4
      type: snowflake
      user: your_user
      warehouse: your_warehouse
  target: dev
  
```

## 📂 Project Structure
```
/dbt_project
│── models
│   ├── staging/
│   │   ├── stg_listings.sql
│   │   ├── stg_calendar.sql
│   │   ├── stg_reviews.sql
│   │   ├── schema.yml
│   ├── marts/dimensions/
│   │   │   ├── dim_hosts.sql
│   │   │   ├── dim_listings.sql
│   │   │   ├── dim_reviews.sql
│   │   │   ├── schema.yml
│   ├── marts/facts/
│   │   │   ├── fact_bookings.sql
│   │   │   ├── fact_pricing_trends.sql
│   │   │   ├── fact_availability_trends.sql
│   │   │   ├── fact_listings_performance.sql
│   │   │   ├── schema.yml
│   ├── final/
│   │   ├── final_airbnb_listings.sql
│   │   ├── schema.yml
│── snapshots
│   ├── host_snapshot.sql
│── dbt_project.yml
│── sources.yml
│── exposure_dasboard.yml
│── packages.yml
│── README.md
```

### **Install dbt Dependencies**
```sh
dbt deps
```

### **Run dbt Models**
```sh
dbt run
```
To run a specific model:
```sh
dbt run --select fact_bookings
```

### **Test and Document Models**
```sh
dbt test
dbt docs generate && dbt docs serve
```

## 📊 Model Descriptions

### **1. Staging Layer**

stg_listings.sql - Cleans and standardizes listings data, handling missing values and normalizing column formats.

stg_calendar.sql - Processes daily availability and pricing data, filtering out inconsistencies.

stg_reviews.sql - Prepares reviews data, extracting relevant metadata for further transformation.

schema.yml - Defines relationships, constraints, and metadata for the staging models.

### **2. Marts Layer**
#### **Dimensions**

dim_hosts.sql - Aggregates host details, including number of listings and ratings.

dim_listings.sql - Stores detailed Airbnb listings data, including property type, room type, location, and host info.

dim_reviews.sql - Structures review data for analysis, including review frequency and sentiment trends.

schema.yml - Defines structure, constraints, and documentation for dimension tables.

#### **Facts**

fact_bookings.sql - (Incremental model) Stores confirmed bookings, linking listings and availability data.

fact_pricing_trends.sql - Tracks pricing variations over time, identifying seasonal pricing trends.

fact_availability_trends.sql - Analyzes occupancy rates, showing which properties are booked most frequently.

fact_listings_performance.sql - Computes key listing performance metrics, including revenue, booking rate, and review count.

schema.yml - Defines structure, constraints, and business logic for fact tables.

### **3. Final Aggregated Model**
final_airbnb_listings.sql - Combines listings, bookings, pricing, and reviews for comprehensive reporting.

schema.yml - Metadata and constraints for the final aggregated model.

### ⚙️ Configuration Files

dbt_project.yml - Defines dbt project settings, model configurations, and default behaviors.

sources.yml - Configures data sources (AWS S3 → Snowflake), defining schemas and table sources.

exposure_dashboard.yml - Tracks dbt model usage in reporting tools like Looker Studio.

packages.yml - Manages dbt dependencies and external packages.



## 🚀 Running Tests and Models
- Run all models:
  ```sh
  dbt run
  ```
- Run tests to validate transformations:
  ```sh
  dbt test
  ```
- Run a specific model:
  ```sh
  dbt run --select <model-name>
  ```
- Run incremental models:
  ```sh
  dbt run --full-refresh
  ```

## 🔄 Setting Up GitHub Actions for CI/CD
To automate `dbt run` and `dbt test` on every commit:
1. Create `.github/workflows/dbt-ci.yml` with:
```yaml
   name: "DBT CI/CD Pipeline"

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:  # Allows manual execution

jobs:
  dbt-ci-cd:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.9"

      - name: Install DBT & Snowflake Adapter
        run: |
          pip install dbt-core dbt-snowflake

      - name: Configure DBT Profiles
        run: |
          mkdir -p ~/.dbt
          echo "${{ secrets.DBT_PROFILES }}" > ~/.dbt/profiles.yml

      - name: Install DBT Dependencies
        run: dbt deps

      - name: Run DBT Tests
        run: dbt test  # Runs data quality tests

      - name: Run DBT Models
        run: dbt run --exclude tag:skip_ci  # Runs models except those tagged as skip_ci

      - name: Check DBT Model Performance
        run: |
          cat target/run_results.json | jq '.results[] | {model: .unique_id, time: .execution_time}'

```

2. **Secure your credentials**: Store sensitive values (like Snowflake credentials) in **GitHub Secrets** instead of hardcoding them.
3. Commit and push the workflow file to trigger automated runs.


## 🔗 Integrations
### **1. Looker Studio Dashboard**
- Connected Snowflake to Looker Studio for real-time analytics.
- Includes KPI scorecards, sales trends, and customer segmentation.
- For exposure_dashboard replace the link with your report link 
## 📈 Key Findings
- **Data Cleansing & Transformation**: Ensures accurate and standardized datasets.
- **Optimized Queries**: Snowflake’s clustering and indexing improve performance.
- **CI/CD with GitHub Actions**: Automates testing and deployment of dbt models.
- **Incremental Models**: Ensures faster updates by processing only new data.

