

WITH review_stats AS (
    SELECT
        listing_id,
        MIN(date) AS first_review,
        MAX(date) AS last_review,
        COUNT(*) AS total_reviews
    FROM AIRBNB.PROD.stg_reviews
    GROUP BY listing_id
)

SELECT
    rs.listing_id,
    rs.first_review,
    rs.last_review,
    rs.total_reviews,
    l.review_scores_rating  -- Getting rating from `stg_listings`
FROM review_stats rs
LEFT JOIN AIRBNB.PROD.stg_listings l
    ON rs.listing_id = l.listing_id