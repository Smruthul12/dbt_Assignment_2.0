SELECT
    host_id,
    host_name,
    host_total_listings_count AS total_listings,
    host_response_rate::NUMBER / 100 AS response_rate,  -- Convert percentage
    CASE 
        WHEN host_is_superhost = 't' THEN TRUE 
        ELSE FALSE 
    END AS is_superhost
FROM AIRBNB.DEV.stg_listings
GROUP BY 1, 2, 3, 4, 5