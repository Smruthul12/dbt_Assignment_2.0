






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and review_scores_rating >= 0 and review_scores_rating <= 5
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







