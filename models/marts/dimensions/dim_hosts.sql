{{
    config(
        materialized='table'
    )
}}
WITH ranked_hosts AS (
    SELECT
        host_id,
        host_name,
        host_total_listings_count AS total_listings,
        host_response_rate::NUMBER / 100 AS response_rate,  -- Convert percentage
        CASE 
            WHEN host_is_superhost = 't' THEN TRUE 
            ELSE FALSE 
        END AS is_superhost,
        CAST(updated_date AS TIMESTAMP_NTZ) AS updated_date,
        ROW_NUMBER() OVER (PARTITION BY host_id ORDER BY updated_date DESC) AS row_num
    FROM {{ ref('stg_listings') }}
)
SELECT 
    host_id, 
    host_name, 
    total_listings, 
    response_rate, 
    is_superhost, 
    updated_date
FROM ranked_hosts
WHERE row_num = 1
