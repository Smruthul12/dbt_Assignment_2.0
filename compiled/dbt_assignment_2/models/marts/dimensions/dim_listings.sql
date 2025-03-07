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
FROM AIRBNB.PROD.stg_listings