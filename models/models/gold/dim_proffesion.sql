{{ config(
    materialized='table'
) }}

WITH unique_professions AS (
    SELECT DISTINCT
        order_profession_id,
        order_profession_name
    FROM {{ ref('silver_dedu_ALL_Updates') }}
)

SELECT
    monotonically_increasing_id() AS profession_key,
    order_profession_id AS profession_id,
    order_profession_name AS profession_name
FROM unique_professions
ORDER BY order_profession_id
