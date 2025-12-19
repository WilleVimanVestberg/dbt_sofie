{{ config(
    materialized = "table",
    unique_key = "property_id",
    incremental_strategy = "merge"
) }}

WITH base AS (

    SELECT
         -- Flatten address-struct
        NULLIF(TRIM(address.city), '') AS city,
        NULLIF(TRIM(address.country), '') AS country,
        NULLIF(TRIM(address.postCode), '') AS post_code,
        NULLIF(TRIM(address.streetAddress), '') AS street_address,
        CONCAT(
            NULLIF(TRIM(address.streetAddress), ''), ', ',
            NULLIF(TRIM(address.postCode), ''), ', ',
            NULLIF(TRIM(address.city), ''), ', ',
            NULLIF(TRIM(address.country), '')
        ) AS full_address,

        -- Extract district from designation
        NULLIF(TRIM(REGEXP_EXTRACT(designation, ',\\s*(.*)$', 1)), '') AS district,

        -- Standardize column names
        NULLIF(TRIM(category), '') AS property_category,
        NULLIF(TRIM(countryCode), '') AS country_code,
        NULLIF(TRIM(designation), '') AS designation,
        id AS property_id,
        NULLIF(TRIM(ownerName), '') AS owner_company_name,
        NULLIF(TRIM(ownerOrganisationNumber), '') AS owner_organisation_number,
        NULLIF(TRIM(ownershipStatus), '') AS ownership_status,
        NULLIF(TRIM(popularName), '') AS property_popular_name,
        NULLIF(TRIM(propertyManager), '') AS property_manager,
        NULLIF(TRIM(propertyManagerCode), '') AS property_manager_code,
        NULLIF(TRIM(propertyName), '') AS property_name,
        NULLIF(TRIM(propertyNumber), '') AS property_number,
        NULLIF(TRIM(region), '') AS region,
        rentalObjectArea AS property_rental_area,
        spaceArea AS property_area,
        NULLIF(TRIM(technicalManager), '') AS technical_manager,
        NULLIF(TRIM(technicalManagerCode), '') AS technical_manager_code,

        -- Metadata
        ingestion_id,
        timestamp_raw_ingestion,
        source_file,
        'propertymanager_properties' AS source_system

    FROM {{ source('bronze', 'propertymanager_properties') }}
)

-- deduplicera baserat på property_id med senaste timestamp_raw_ingestion
, deduped AS (
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY property_id
                ORDER BY timestamp_raw_ingestion DESC
            ) AS rn
        FROM base
    )
    WHERE rn = 1
)

SELECT * 
FROM deduped

-- {% if is_incremental() %}
--     -- endast nya eller uppdaterade rader baserat på primary key / timestamp
--     WHERE property_id NOT IN (
--         SELECT property_id FROM {{ this }}
--     )
-- {% endif %}
