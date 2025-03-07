






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and final_price >= 0
)
 as expression


    from AIRBNB.DEV.fact_pricing_trends
    

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







