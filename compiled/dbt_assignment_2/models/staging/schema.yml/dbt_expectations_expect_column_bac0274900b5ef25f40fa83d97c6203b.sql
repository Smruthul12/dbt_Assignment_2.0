






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and minimum_nights >= 1
)
 as expression


    from AIRBNB.DEV.stg_calendar
    

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







