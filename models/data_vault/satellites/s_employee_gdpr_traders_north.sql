{{ config(
    materialized='incremental'
) }}

SELECT DISTINCT

    h_employee.hk_h_employee AS hk_h_employee,

    stage_employee_traders_north.country AS country,
    stage_employee_traders_north.lastname AS lastname,
    stage_employee_traders_north.firstname AS firstname,
    stage_employee_traders_north.title AS title,
    stage_employee_traders_north.titleofcourtesy AS titleofcourtesy,
    stage_employee_traders_north.birthdate AS birthdate,
    stage_employee_traders_north.address AS address,
    stage_employee_traders_north.city AS city,
    stage_employee_traders_north.region AS region,
    stage_employee_traders_north.postalcode AS postalcode,
    stage_employee_traders_north.homephone AS homephone,
    stage_employee_traders_north.reportsto AS reportsto,

    stage_employee_traders_north.dss_change_hash_employee_gdpr_traders_north
        AS dss_change_hash,

    stage_employee_traders_north.dss_record_source
        AS dss_record_source,

    stage_employee_traders_north.dss_load_date
        AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    {% if is_incremental() %}
        COALESCE(current_rows.dss_version, 0) + 1
    {% else %}
        1
    {% endif %} AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('h_employee') }} AS h_employee

INNER JOIN {{ ref('stg_employee_traders_north') }}
    AS stage_employee_traders_north

    ON h_employee.hk_h_employee =
       stage_employee_traders_north.hk_h_employee

{% if is_incremental() %}

LEFT JOIN (

    SELECT
        hk_h_employee,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_employee

) AS current_rows

    ON stage_employee_traders_north.hk_h_employee =
       current_rows.hk_h_employee

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS s_employee_gdpr_traders_north

    WHERE stage_employee_traders_north.hk_h_employee =
          s_employee_gdpr_traders_north.hk_h_employee

      AND stage_employee_traders_north.dss_change_hash_employee_gdpr_traders_north =
          s_employee_gdpr_traders_north.dss_change_hash

      AND current_rows.dss_start_date =
          s_employee_gdpr_traders_north.dss_start_date

)

{% endif %}