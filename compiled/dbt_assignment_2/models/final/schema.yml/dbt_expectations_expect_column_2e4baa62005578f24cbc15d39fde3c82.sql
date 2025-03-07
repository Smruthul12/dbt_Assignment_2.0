

with all_values as (

    select
        room_type as value_field

    from AIRBNB.PROD.final_airbnb_listings
    

),
set_values as (

    select
        cast('Entire home/apt' as TEXT) as value_field
    union all
    select
        cast('Private room' as TEXT) as value_field
    union all
    select
        cast('Shared room' as TEXT) as value_field
    union all
    select
        cast('Hotel room' as TEXT) as value_field
    
    
),
validation_errors as (
    -- values from the model that are not in the set
    select
        v.value_field
    from
        all_values v
        left join
        set_values s on v.value_field = s.value_field
    where
        s.value_field is null

)

select *
from validation_errors

