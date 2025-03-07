# 🚀 Airbnb London Analytics with dbt, Snowflake, AWS S3, and GitHub Actions

## 📌 Prerequisites
- **dbt Core** installed ([Installation Guide](https://docs.getdbt.com/docs/core/installation))
- **VS Code & dbt Power User Extension**
- **Snowflake** account and credentials
- **AWS S3 bucket (for storing datasets)**
- **Git & GitHub (for version control and CI/CD)**

## 📥 Dataset
We use the **[Airbnb London dataset](http://insideairbnb.com/get-the-data/)**, which contains listings, reviews, and calendar availability data.

### Preparing the Data:
1. Download the dataset (CSV format) from the link above.
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
  STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket/airbnb/');
```

### 🏗️ Setting Up Data in Snowflake:
```sql
CREATE DATABASE airbnb_dbt;
USE DATABASE airbnb_dbt;
CREATE SCHEMA london;

CREATE WAREHOUSE airbnb_wh_dbt WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;
```

### 📤 Creating External Stage and Loading Data:
```sql
CREATE OR REPLACE STAGE airbnb_dbt.external_stages.s3_data
    URL = 's3://your-bucket/airbnb/'
    STORAGE_INTEGRATION = s3_int;

COPY INTO airbnb_dbt.london.raw_listings
FROM @airbnb_dbt.external_stages.s3_data
FILE_FORMAT = (TYPE = CSV, FIELD_OPTIONALLY_ENCLOSED_BY='"');
```

## **Configure dbt**
### **Location of profiles.yml:**
```sh
C:\Users\YourUsername\.dbt\profiles.yml
```
Edit `profiles.yml`:
```yml
airbnb_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_snowflake_account
      user: your_user
      password: your_password
      role: your_role
      database: airbnb_dbt
      warehouse: airbnb_wh_dbt
      schema: london
      threads: 4
      client_session_keep_alive: False
```

## 📂 Project Structure
```
/dbt_project
│── models
│   ├── staging/
│   │   ├── raw_listings.sql  # Cleans raw data
│   ├── dimensions/
│   │   ├── dim_hosts.sql
│   │   ├── dim_listings.sql
│   ├── facts/
│   │   ├── fact_bookings.sql
│   │   ├── fact_pricing.sql
│── dbt_project.yml
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

## 🔄 Automating dbt Runs with GitHub Actions
To automate `dbt run` and `dbt test` on every commit:

1. Create `.github/workflows/dbt-ci.yml`:
```yaml
name: "DBT CI/CD Pipeline"

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

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
        run: dbt test

      - name: Run DBT Models
        run: dbt run --exclude tag:skip_ci
```

2. **Store credentials securely:** Use **GitHub Secrets** to store Snowflake credentials.

## 📈 Key Insights
- **Data Cleansing & Transformation**: Ensures accurate and standardized datasets.
- **Optimized Queries**: Snowflake’s clustering and indexing improve performance.
- **CI/CD with GitHub Actions**: Automates testing and deployment of dbt models.
- **Incremental Models**: Ensures faster updates by processing only new data.

