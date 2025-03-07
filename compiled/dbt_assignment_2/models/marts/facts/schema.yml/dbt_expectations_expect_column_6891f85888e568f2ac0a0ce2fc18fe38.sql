






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and avg_adjusted_price_per_night >= 0
)
 as expression


    from AIRBNB.DEV.fact_bookings
    

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







