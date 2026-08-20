{{ config(
    materialized='incremental'
) }}

SELECT DISTINCT

    h_employee.hk_h_employee AS hk_h_employee,

    stage_employee_traders_south.extension AS extension,

    stage_employee_traders_south.dss_change_hash_employee_hroc_traders_south
        AS dss_change_hash,

    stage_employee_traders_south.dss_record_source
        AS dss_record_source,

    stage_employee_traders_south.dss_load_date
        AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    {% if is_incremental() %}
        COALESCE(current_rows.dss_version, 0) + 1
    {% else %}
        1
    {% endif %} AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('h_employee') }} AS h_employee

INNER JOIN {{ ref('stg_employee_traders_south') }}
    AS stage_employee_traders_south

    ON h_employee.hk_h_employee =
       stage_employee_traders_south.hk_h_employee

{% if is_incremental() %}

LEFT JOIN (

    SELECT
        hk_h_employee,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_employee

) AS current_rows

    ON stage_employee_traders_south.hk_h_employee =
       current_rows.hk_h_employee

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS s_employee_hroc_traders_south

    WHERE stage_employee_traders_south.hk_h_employee =
          s_employee_hroc_traders_south.hk_h_employee

      AND stage_employee_traders_south.dss_change_hash_employee_hroc_traders_south =
          s_employee_hroc_traders_south.dss_change_hash

      AND current_rows.dss_start_date =
          s_employee_hroc_traders_south.dss_start_date

)

{% endif %}