SELECT
    COUNT(*) AS null_count
FROM {{ ref('silver_dedu_ML') }}
WHERE RegionId IS NULL
