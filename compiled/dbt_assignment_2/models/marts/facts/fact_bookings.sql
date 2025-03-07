

WITH calendar_data AS (
    SELECT
        listing_id,
        date AS booking_date,
        available,
        price,
        adjusted_price
    FROM AIRBNB.PROD.stg_calendar
    
    
),

aggregated_bookings AS (
    SELECT
        listing_id,
        COUNT(*) AS total_days,
        SUM(CASE WHEN available = 't' THEN 1 ELSE 0 END) AS total_available_days,
        SUM(CASE WHEN available = 'f' THEN 1 ELSE 0 END) AS total_booked_days,
        AVG(price) AS avg_price_per_night,
        AVG(CASE 
                WHEN adjusted_price = 0 OR adjusted_price IS NULL THEN price 
                ELSE adjusted_price 
            END) AS avg_adjusted_price_per_night
    FROM calendar_data
    GROUP BY listing_id
)

SELECT
    ab.listing_id,
    dl.host_id,
    dl.updated_date,
    ab.total_days,
    ab.total_available_days,
    ab.total_booked_days,
    (ab.total_booked_days * 1.0 / NULLIF(ab.total_days, 0)) AS occupancy_rate,
    ab.avg_price_per_night,
    ab.avg_adjusted_price_per_night,
    (ab.total_booked_days * ab.avg_adjusted_price_per_night) AS total_revenue
FROM aggregated_bookings ab
JOIN AIRBNB.PROD.dim_listings dl ON ab.listing_id = dl.listing_id