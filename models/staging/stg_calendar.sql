SELECT
    listing_id,
    date,
    available,
    COALESCE(NULLIF(TRY_CAST(REPLACE(price, '$', '') AS FLOAT), NULL), 0) AS price_numeric,
    COALESCE(NULLIF(TRY_CAST(REPLACE(adjusted_price, '$', '') AS FLOAT), NULL), 0) AS adjusted_price_numeric,
    GREATEST(COALESCE(minimum_nights, 1), 1) AS minimum_nights,
    GREATEST(COALESCE(maximum_nights, 30), 1) AS maximum_nights
FROM {{ source('airbnb', 'calendar') }}
