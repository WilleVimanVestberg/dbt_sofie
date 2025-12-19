{{ config(
    materialized='table'
) }}

-- CTE för senaste dedu per property
with dedu as (
    select *
    from (
        select 
            property_number,
            property_name,
            region,
            dedu_property_id,
            row_number() over (
                partition by property_number
                order by order_latest_work_update_timestamp desc
            ) as rn
        from {{ ref('silver_dedu_ALL_Updates') }}  -- dbt referens till silver.dedu_final
    ) tmp
    where rn = 1
)

select
    -- Primary key
    row_number() over (order by v.property_number) as properties_key,
    
    v.property_number,
    v.property_name,
    v.cid,
    v.property_begin_timestamp,
    v.property_end_timestamp,

    -- Hantera NULL
    coalesce(pm.city, 'Okänd') as city,
    coalesce(pm.country, 'Sverige') as country,
    coalesce(pm.country_code, 'SWE') as country_code,
    coalesce(pm.post_code, 'Okänd') as post_code,
    coalesce(pm.street_address, 'Okänd') as street_address,
    coalesce(pm.full_address, 'Okänd') as full_address,
    coalesce(pm.district, 'Okänd') as district,
    coalesce(pm.region, d.region, 'Okänd') as region,
    coalesce(pm.property_category, 'Okänd') as property_category,
    coalesce(pm.designation, 'Okänd') as designation,
    coalesce(pm.property_id, -1) as property_id,
    coalesce(pm.owner_company_name, 'Okänd') as owner_company_name,
    coalesce(pm.owner_organisation_number, 'Okänd') as owner_organisation_number,
    coalesce(pm.ownership_status, 'Okänd') as ownership_status,
    coalesce(pm.property_popular_name, 'Okänd') as property_popular_name,
    coalesce(pm.property_manager, 'Okänd') as property_manager,
    coalesce(v.property_manager_code, pm.property_manager_code, 'Okänd') as property_manager_code,
    coalesce(pm.property_rental_area, 0) as property_rental_area,
    coalesce(pm.property_area, 0) as property_area,
    coalesce(pm.technical_manager, 'Okänd') as technical_manager,
    coalesce(v.technical_manager_code, pm.technical_manager_code, 'Okänd') as technical_manager_code,
    coalesce(d.dedu_property_id, -1) as dedu_property_id

from {{ ref('silver_visma_properties') }} v
left join {{ ref('silver_propertymanager_properties') }} pm
    on v.property_number = pm.property_number
left join dedu d
    on v.property_number = d.property_number

where v.cid not in ('4100', '6700')
