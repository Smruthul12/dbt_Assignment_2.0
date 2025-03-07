SELECT
    listing_id,
    date,
    reviewer_id,
    COALESCE(reviewer_name, 'Unknown') AS reviewer_name,
    comments
FROM airbnb.raw.reviews
WHERE comments IS NOT NULL