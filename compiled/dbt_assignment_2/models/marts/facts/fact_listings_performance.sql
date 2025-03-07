WITH bookings AS (
    SELECT 
        listing_id,
        total_booked_days,
        total_available_days,
        occupancy_rate,
        avg_price_per_night,
        avg_adjusted_price_per_night,
        total_revenue
    FROM AIRBNB.DEV.fact_bookings
),
reviews AS (
    SELECT 
        listing_id,
        AVG(review_scores_rating) AS review_scores_rating,  -- Aggregate rating if multiple reviews exist
        COUNT(*) AS total_reviews,
        MIN(DATE_TRUNC('month', first_review)) AS first_review_month,
        MAX(DATE_TRUNC('month', last_review)) AS last_review_month,
        CASE 
            WHEN DATEDIFF(MONTH, MIN(first_review), MAX(last_review)) = 0 THEN COUNT(*)
            ELSE ROUND(COUNT(*) / NULLIF(DATEDIFF(MONTH, MIN(first_review), MAX(last_review)), 0), 2)
        END AS reviews_per_month
    FROM AIRBNB.DEV.dim_reviews
    GROUP BY listing_id
)
SELECT 
    b.listing_id,
    l.host_id,
    l.property_type,
    l.room_type,
    b.total_booked_days,
    b.total_available_days,
    b.occupancy_rate,
    b.avg_price_per_night,
    b.avg_adjusted_price_per_night,
    b.total_revenue,
    COALESCE(r.review_scores_rating, 0) AS review_scores_rating,  
    COALESCE(r.reviews_per_month, 0) AS reviews_per_month
FROM bookings b
JOIN AIRBNB.DEV.dim_listings l ON b.listing_id = l.listing_id
LEFT JOIN reviews r ON b.listing_id = r.listing_id