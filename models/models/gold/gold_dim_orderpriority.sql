{{ config(
    materialized='table'
) }}

select
    -- Primary key
    monotonically_increasing_id() as order_priority_key,

    -- Dimension info
    task_priority_id as priority_id,
    task_priority_name as priority_name,
    task_priority_description as priority_description,

    -- Days to fix an order
    case
        when task_priority_id = 30 then 0
        when task_priority_id = 31 then 1
        when task_priority_id = 32 then 5
        else null
    end as sla_days

from (
    -- Select unique combo of id, name and description from silver
    select distinct
        task_priority_id,
        task_priority_name,
        task_priority_description
    from {{ ref('silver_dedu_ALL_Updates') }}
) t
order by priority_id


