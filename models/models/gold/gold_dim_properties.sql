{{ config(
    materialized='table'
) }}

WITH dedu AS (
    SELECT *
    FROM (
        SELECT 
            property_number,
            property_name,
            region,
            dedu_property_id,
            row_number() OVER (
                PARTITION BY property_number
                ORDER BY order_latest_work_update_timestamp DESC
            ) AS rn   
    )
)