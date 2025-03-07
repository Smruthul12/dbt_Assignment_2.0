






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and longitude >= -180 and longitude <= 180
)
 as expression


    from AIRBNB.DEV.dim_listings
    

),
validation_errors as (

    select
        *
    from
        grouped_expression
    where
        not(expression = true)

)

select *
from validation_errors







