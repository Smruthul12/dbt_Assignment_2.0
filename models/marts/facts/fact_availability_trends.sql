{{ 
    config(
        materialized='incremental',
        unique_key='listing_id',
        cluster_by=['listing_id']
    ) 
}}

WITH calendar_data AS (
    SELECT
        listing_id,
        date AS availability_date,
        available
    FROM {{ ref('stg_calendar') }}
),

aggregated_availability AS (
    SELECT
        listing_id,
        availability_date,
        COUNT(*) AS total_days,
        SUM(CASE WHEN available = 't' THEN 1 ELSE 0 END) AS total_available_days,
        SUM(CASE WHEN available = 'f' THEN 1 ELSE 0 END) AS total_booked_days,
        (SUM(CASE WHEN available = 'f' THEN 1 ELSE 0 END) * 1.0 / NULLIF(COUNT(*), 0)) AS occupancy_rate
    FROM calendar_data
    {% if is_incremental() %}
    -- Only process new data for incremental runs
    WHERE availability_date > (SELECT MAX(availability_date) FROM {{ this }})
    {% endif %}
    GROUP BY listing_id, availability_date
)

SELECT
    a.listing_id,
    l.host_id,
    a.availability_date,
    a.total_days,
    a.total_available_days,
    a.total_booked_days,
    a.occupancy_rate
FROM aggregated_availability a
JOIN {{ ref('dim_listings') }} l ON a.listing_id = l.listing_id
