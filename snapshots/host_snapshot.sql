{% snapshot host_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='updated_date'
    )
}}

SELECT
    host_id,
    host_name,
    total_listings,  
    response_rate,  
    is_superhost,
    updated_date  
FROM {{ ref('dim_hosts') }}

{% endsnapshot %}
