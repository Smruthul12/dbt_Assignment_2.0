{{
    config(
        materialized='view',
        cluster_by=['listing_id']
    )
}}

SELECT
    listing_id,
    host_id,
    neighbourhood_cleansed AS neighborhood,
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
FROM {{ ref('stg_listings') }}
