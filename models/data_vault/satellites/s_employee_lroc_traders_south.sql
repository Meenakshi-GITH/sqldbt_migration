{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

WITH stage AS (

    SELECT
        hk_h_employee,
        hiredate,
        dss_change_hash_employee_lroc_traders_south AS dss_change_hash,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stg_employee_traders_south') }}

),

current_rows AS (

    {% if is_incremental() %}

    SELECT
        hk_h_employee,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_employee

    {% else %}

    SELECT
        CAST(NULL AS VARCHAR) AS hk_h_employee,
        CAST(NULL AS TIMESTAMP) AS dss_start_date,
        CAST(NULL AS INTEGER) AS dss_version
    WHERE 1 = 0

    {% endif %}

)

SELECT DISTINCT
    stage.hk_h_employee AS hk_h_employee,
    stage.hiredate AS hiredate,
    stage.dss_change_hash AS dss_change_hash,
    stage.dss_record_source AS dss_record_source,
    stage.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM stage

LEFT JOIN current_rows
    ON stage.hk_h_employee = current_rows.hk_h_employee

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} AS target

    WHERE stage.hk_h_employee = target.hk_h_employee
      AND stage.dss_change_hash = target.dss_change_hash
      AND current_rows.dss_start_date = target.dss_start_date

)

{% endif %}