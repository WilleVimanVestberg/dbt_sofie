{{ config(
    materialized = "incremental",
    incremental_strategy = "merge",
    unique_key = "record_hash"
) }}

SELECT
    cid,
    year,
    period,
    serie,
    vouno,
    rowno,
    date,
    altered,
    account,
    resacc,
    currency,
    amount,
    foramount,
    number,
    o1,
    o2,
    o3,
    o4,
    o5,
    o6,
    o7,
    o8,
    xfreetext,
    extraamount,
    group1,
    group2,
    group3,
    group4,
    vatcode,
    crtype,
    creator,
    basecurrency,
    baseamount,
    ingestion_id,
    timestamp_raw_ingestion,
    source_file,

    {{ record_hash([
        'cid',
        'year',
        'period',
        'o1',
        'o3', 
        'serie',
        'vouno',
        'rowno',
        'account',
        'amount',
        'foramount',
        'currency'
    ]) }} AS record_hash,

    current_timestamp() AS binary_timestamp

FROM {{ source('bronze', 'visma_vourowx') }}

{% if is_incremental() %}
WHERE timestamp_raw_ingestion > (
    SELECT MAX(timestamp_raw_ingestion) FROM {{ this }}
)
{% endif %}
