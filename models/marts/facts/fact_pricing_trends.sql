{{ 
    config(
        materialized='incremental',
        unique_key='listing_id',
        cluster_by=['listing_id', 'pricing_date']
    ) 
}}

WITH daily_prices AS (
    SELECT
        listing_id,
        date AS pricing_date,
        COALESCE(NULLIF(adjusted_price, 0), price) AS final_price
    FROM {{ ref('stg_calendar') }}
    {% if is_incremental() %}
    WHERE date > (SELECT MAX(pricing_date) FROM {{ this }})  -- Only process new data
    {% endif %}
),
price_trends AS (
    SELECT
        listing_id,
        pricing_date,
        final_price,
        AVG(final_price) OVER (
            PARTITION BY listing_id 
            ORDER BY pricing_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS avg_price_7d,
        AVG(final_price) OVER (
            PARTITION BY listing_id 
            ORDER BY pricing_date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS avg_price_30d
    FROM daily_prices
)
SELECT
    pt.listing_id,
    pt.pricing_date,
    pt.final_price,
    pt.avg_price_7d,
    pt.avg_price_30d
FROM price_trends pt
