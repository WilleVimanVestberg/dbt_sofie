{{ config(
    materialized = "table",
    unique_key = "property_id",
    incremental_strategy = "merge"
) }}

WITH
-- Property information from visma_objectx
visma_base AS (
    SELECT 
        object AS property_number,
        cid AS cid,
        name AS property_name,
        usergroup1 AS property_manager_code,
        usergroup2 AS technical_manager_code,
        objectbegin AS property_begin_timestamp,
        objectend AS property_end_timestamp,
        ingestion_id AS ingestion_id,
        timestamp_raw_ingestion AS timestamp_raw_ingestion,
        source_file AS source_file,
        'visma_objectx' AS source_system
    FROM {{ source('bronze', 'visma_objectx') }}
    WHERE no = 1
),

-- Find the missing properties in propertymanager_properties (missing = sold)
visma_missing_pm AS (
    SELECT v.*
    FROM visma_base v
    LEFT JOIN {{ ref('silver_propertymanager_properties') }} pm
        ON pm.property_number = v.property_number
    WHERE pm.property_number IS NULL
)

-- Select columns for silver.visma_properties
SELECT
    v.property_number,
    v.cid,
    v.property_name,
    v.property_manager_code,
    v.technical_manager_code,
    v.property_begin_timestamp,

    -- Add end-date for properties that are sold but not updated in visma
    CASE
        WHEN v.property_number IN (SELECT property_number FROM visma_missing_pm)
             AND v.property_end_timestamp IS NULL
        THEN MAKE_TIMESTAMP(
                2024,
                12, 31, 0, 0, 0
             )
        ELSE v.property_end_timestamp
    END AS property_end_timestamp,

    v.ingestion_id,
    v.timestamp_raw_ingestion,
    v.source_file,
    v.source_system

FROM visma_base v
-- Remove fake properties
WHERE cid IS NOT NULL 
  AND v.property_number < '99001' 
  AND v.property_number != '6202'
