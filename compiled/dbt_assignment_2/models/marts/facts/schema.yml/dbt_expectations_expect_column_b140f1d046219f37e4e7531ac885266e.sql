






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and occupancy_rate >= 0 and occupancy_rate <= 1
)
 as expression


    from AIRBNB.PROD.fact_availability_trends
    

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







