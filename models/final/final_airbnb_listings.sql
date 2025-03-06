{{ config(materialized='table') }}

WITH listings AS (
    SELECT 
        listing_id,
        host_id,
        neighborhood,
        latitude,
        longitude,
        property_type,
        room_type,
        accommodates,
        bedrooms,
        beds,
        price,
        minimum_nights,
        maximum_nights,
        updated_date
    FROM {{ ref('dim_listings') }}
),

bookings AS (
    SELECT 
        listing_id,
        total_days,
        total_available_days,
        total_booked_days,
        occupancy_rate,
        avg_price_per_night,
        avg_adjusted_price_per_night,
        total_revenue
    FROM {{ ref('fact_bookings') }}
),

pricing AS (
    SELECT 
        listing_id,
        AVG(avg_price_7d) AS avg_price_trend_7d,
        AVG(avg_price_30d) AS avg_price_trend_30d
    FROM {{ ref('fact_pricing_trends') }}
    GROUP BY listing_id
),

availability AS (
    SELECT 
        listing_id,
        MAX(availability_date) AS last_updated_date,
        AVG(total_available_days) AS avg_available_days
    FROM {{ ref('fact_availability_trends') }}
    GROUP BY listing_id
)

SELECT 
    l.*,  -- All listing details
    COALESCE(b.total_days, 0) AS total_days,
    COALESCE(b.total_available_days, 0) AS total_available_days,
    COALESCE(b.total_booked_days, 0) AS total_booked_days,
    COALESCE(b.occupancy_rate, 0) AS occupancy_rate,
    COALESCE(b.avg_price_per_night, 0) AS avg_price_per_night,
    COALESCE(b.avg_adjusted_price_per_night, 0) AS avg_adjusted_price_per_night,
    COALESCE(b.total_revenue, 0) AS total_revenue,
    COALESCE(p.avg_price_trend_7d, 0) AS avg_price_trend_7d,
    COALESCE(p.avg_price_trend_30d, 0) AS avg_price_trend_30d,
    COALESCE(a.last_updated_date, CURRENT_DATE) AS last_updated_date,
    COALESCE(a.avg_available_days, 0) AS avg_available_days
FROM listings l
LEFT JOIN bookings b ON l.listing_id = b.listing_id
LEFT JOIN pricing p ON l.listing_id = p.listing_id
LEFT JOIN availability a ON l.listing_id = a.listing_id
