






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and total_available_days >= 0
)
 as expression


    from AIRBNB.DEV.fact_availability_trends
    

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







