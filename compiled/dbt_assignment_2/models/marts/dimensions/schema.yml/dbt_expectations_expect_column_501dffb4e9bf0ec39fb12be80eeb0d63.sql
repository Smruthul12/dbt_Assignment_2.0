






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and response_rate >= 0 and response_rate <= 1
)
 as expression


    from AIRBNB.DEV.dim_hosts
    

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







