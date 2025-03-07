

with all_values as (

    select
        is_superhost as value_field

    from AIRBNB.PROD.dim_hosts
    

),
set_values as (

    select
        cast('True' as TEXT) as value_field
    union all
    select
        cast('False' as TEXT) as value_field
    
    
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

