{{ config(
    materialized='incremental'
) }}

WITH source_customers AS (

    SELECT DISTINCT
        hk_h_customer,
        customer_name,
        dss_record_source,
        dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time
    FROM {{ ref('stg_customer_traders_south') }}

    UNION ALL

    SELECT DISTINCT
        hk_h_customer,
        customer_name,
        dss_record_source,
        dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time
    FROM {{ ref('stg_customer_traders_north') }}

),

deduplicated AS (

    SELECT
        hk_h_customer,
        customer_name,
        dss_record_source,
        dss_load_date,
        dss_create_time
    FROM source_customers

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY customer_name
        ORDER BY dss_load_date
    ) = 1

)

SELECT
    hk_h_customer,
    customer_name,
    dss_record_source,
    dss_load_date,
    dss_create_time

FROM deduplicated

{% if is_incremental() %}

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS h
    WHERE deduplicated.customer_name = h.customer_name
)

{% endif %}