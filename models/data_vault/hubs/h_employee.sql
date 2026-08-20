{{ config(
    materialized='incremental'
) }}

SELECT DISTINCT
    stage_employee_traders_south.hk_h_employee AS hk_h_employee,
    stage_employee_traders_south.employee_id AS employee_id,
    stage_employee_traders_south.dss_record_source AS dss_record_source,
    stage_employee_traders_south.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_employee_traders_south') }}
    AS stage_employee_traders_south

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS h_employee

    WHERE stage_employee_traders_south.employee_id =
          h_employee.employee_id

)

{% endif %}


UNION ALL


SELECT DISTINCT
    stage_employee_traders_north.hk_h_employee AS hk_h_employee,
    stage_employee_traders_north.employee_id AS employee_id,
    stage_employee_traders_north.dss_record_source AS dss_record_source,
    stage_employee_traders_north.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_employee_traders_north') }}
    AS stage_employee_traders_north

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS h_employee

    WHERE stage_employee_traders_north.employee_id =
          h_employee.employee_id

)

{% endif %}