






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and minimum_nights >= 1
)
 as expression


    from AIRBNB.PROD.dim_listings
    

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







