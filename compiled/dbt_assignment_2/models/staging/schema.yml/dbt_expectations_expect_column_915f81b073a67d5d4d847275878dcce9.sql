




    with grouped_expression as (
    select
        
        
    
  


    
regexp_instr(reviewer_name, '^\s*$', 1, 1, 0, '')


 = 0
 as expression


    from AIRBNB.DEV.stg_reviews
    

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




