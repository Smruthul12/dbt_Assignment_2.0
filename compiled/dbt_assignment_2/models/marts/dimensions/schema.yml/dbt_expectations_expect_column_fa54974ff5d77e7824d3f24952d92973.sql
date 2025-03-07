






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and total_listings >= 0
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







