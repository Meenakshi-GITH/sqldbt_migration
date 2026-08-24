{{
    config(
        materialized='incremental',
        unique_key=['hk_h_customer', 'dss_change_hash'],
        incremental_strategy='append'
    )
}}

WITH current_rows AS (

    SELECT
        hk_h_customer,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_customer

),

stage_data AS (

    SELECT DISTINCT
        hk_h_customer,
        customerid,
        dss_change_hash_customer_lroc_traders_north,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stg_customer_traders_north') }}

)

SELECT DISTINCT

    stage_data.hk_h_customer AS hk_h_customer,

    stage_data.customerid AS customerid,

    stage_data.dss_change_hash_customer_lroc_traders_north AS dss_change_hash,

    stage_data.dss_record_source AS dss_record_source,

    stage_data.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM stage_data

LEFT JOIN current_rows
    ON stage_data.hk_h_customer = current_rows.hk_h_customer

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} AS target

    WHERE stage_data.hk_h_customer = target.hk_h_customer

      AND stage_data.dss_change_hash_customer_lroc_traders_north
          = target.dss_change_hash

      AND current_rows.dss_start_date = target.dss_start_date
)