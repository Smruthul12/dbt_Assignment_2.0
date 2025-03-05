SELECT
    listing_id,
    date,
    reviewer_id,
    COALESCE(reviewer_name, 'Unknown') AS reviewer_name,
    comments
FROM {{ source('airbnb', 'reviews') }}
WHERE comments IS NOT NULL
