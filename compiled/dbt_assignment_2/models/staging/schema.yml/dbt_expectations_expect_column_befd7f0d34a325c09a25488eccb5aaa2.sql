






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and adjusted_price >= 0
)
 as expression


    from AIRBNB.PROD.stg_calendar
    

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







