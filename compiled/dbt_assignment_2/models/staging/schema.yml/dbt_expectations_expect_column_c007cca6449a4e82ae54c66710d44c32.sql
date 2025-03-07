





    with grouped_expression as (
    select
        
        
    
  
( 1=1 and length(
        comments
    ) >= 1
)
 as expression


    from AIRBNB.PROD.stg_reviews
    

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






