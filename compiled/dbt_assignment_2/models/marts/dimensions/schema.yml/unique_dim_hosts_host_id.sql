
    
    

select
    host_id as unique_field,
    count(*) as n_records

from AIRBNB.PROD.dim_hosts
where host_id is not null
group by host_id
having count(*) > 1


