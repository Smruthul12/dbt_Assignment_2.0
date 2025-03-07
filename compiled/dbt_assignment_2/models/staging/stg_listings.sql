
WITH base AS (
    SELECT
        id AS listing_id,
        host_id,
        COALESCE(host_name, 'Unknown Host') AS host_name,
        COALESCE(host_is_superhost, 'N') AS host_is_superhost,
        COALESCE(NULLIF(TRY_CAST(REPLACE(host_response_rate, '%', '') AS FLOAT), NULL),0) AS host_response_rate,
        neighbourhood_cleansed,
        latitude,
        longitude,
        property_type,
        room_type,
        accommodates,
        COALESCE(bedrooms, 0) AS bedrooms,
        COALESCE(beds, 0) AS beds, 
        COALESCE(NULLIF(TRY_CAST(REPLACE(price, '$', '') AS FLOAT), NULL), 0) AS price,
        availability_30,
        availability_60,
        availability_90,
        availability_365,
        COALESCE(review_scores_rating, 0) AS review_scores_rating,
        COALESCE(reviews_per_month, 0) AS reviews_per_month,
        COALESCE(host_total_listings_count, 0) AS host_total_listings_count,
        GREATEST(COALESCE(minimum_nights, 1), 1) AS minimum_nights, 
        GREATEST(COALESCE(maximum_nights, 30), 1) AS maximum_nights,
        calendar_last_scraped,
        last_scraped
    FROM airbnb.raw.listings
),

calendar_update AS (
    SELECT
        listing_id,
        MAX(date) AS updated_date
    FROM AIRBNB.PROD.stg_calendar
    GROUP BY listing_id
)

SELECT 
    base.*,
    COALESCE(calendar_update.updated_date, CURRENT_DATE) AS updated_date
FROM base
LEFT JOIN calendar_update USING (listing_id)