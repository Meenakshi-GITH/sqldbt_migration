{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

{% if is_incremental() %}

WITH current_rows AS (

    SELECT
        hk_h_customer,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_customer

)

SELECT DISTINCT

    stg_customer_traders_south.hk_h_customer AS hk_h_customer,

    stg_customer_traders_south.customerid AS customerid,

    stg_customer_traders_south.dss_change_hash_customer_lroc_traders_south
        AS dss_change_hash,

    stg_customer_traders_south.dss_record_source AS dss_record_source,

    stg_customer_traders_south.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_customer_traders_south') }} AS stg_customer_traders_south

LEFT JOIN current_rows
    ON stg_customer_traders_south.hk_h_customer =
       current_rows.hk_h_customer

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS s_customer_lroc_traders_south

    WHERE stg_customer_traders_south.hk_h_customer =
          s_customer_lroc_traders_south.hk_h_customer

      AND stg_customer_traders_south.dss_change_hash_customer_lroc_traders_south =
          s_customer_lroc_traders_south.dss_change_hash

      AND current_rows.dss_start_date =
          s_customer_lroc_traders_south.dss_start_date
)

{% else %}

SELECT DISTINCT

    stg_customer_traders_south.hk_h_customer AS hk_h_customer,

    stg_customer_traders_south.customerid AS customerid,

    stg_customer_traders_south.dss_change_hash_customer_lroc_traders_south
        AS dss_change_hash,

    stg_customer_traders_south.dss_record_source AS dss_record_source,

    stg_customer_traders_south.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    1 AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_customer_traders_south') }}
    AS stg_customer_traders_south

{% endif %}