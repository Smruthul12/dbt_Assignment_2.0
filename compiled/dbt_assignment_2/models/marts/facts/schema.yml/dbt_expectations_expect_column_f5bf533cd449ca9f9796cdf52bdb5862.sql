






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and reviews_per_month >= 0
)
 as expression


    from AIRBNB.PROD.fact_listings_performance
    

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







