






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and bedrooms >= 0
)
 as expression


    from AIRBNB.PROD.final_airbnb_listings
    

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







