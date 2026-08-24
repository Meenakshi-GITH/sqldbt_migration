{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

{% if is_incremental() %}

WITH current_rows AS (

    SELECT
        hk_h_employee,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_employee

)

SELECT DISTINCT

    src.hk_h_employee AS hk_h_employee,

    src.country AS country,

    src.lastname AS lastname,

    src.firstname AS firstname,

    src.title AS title,

    src.titleofcourtesy AS titleofcourtesy,

    src.birthdate AS birthdate,

    src.address AS address,

    src.city AS city,

    src.region AS region,

    src.postalcode AS postalcode,

    src.homephone AS homephone,

    src.reportsto AS reportsto,

    src.dss_change_hash_employee_gdpr_traders_north
        AS dss_change_hash,

    src.dss_record_source AS dss_record_source,

    src.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    COALESCE(current_rows.dss_version, 0) + 1
        AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_employee_traders_north') }} AS src

LEFT JOIN current_rows
    ON src.hk_h_employee = current_rows.hk_h_employee

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS target

    WHERE src.hk_h_employee =
          target.hk_h_employee

      AND src.dss_change_hash_employee_gdpr_traders_north =
          target.dss_change_hash

      AND current_rows.dss_start_date =
          target.dss_start_date
)

{% else %}

SELECT DISTINCT

    src.hk_h_employee AS hk_h_employee,

    src.country AS country,

    src.lastname AS lastname,

    src.firstname AS firstname,

    src.title AS title,

    src.titleofcourtesy AS titleofcourtesy,

    src.birthdate AS birthdate,

    src.address AS address,

    src.city AS city,

    src.region AS region,

    src.postalcode AS postalcode,

    src.homephone AS homephone,

    src.reportsto AS reportsto,

    src.dss_change_hash_employee_gdpr_traders_north
        AS dss_change_hash,

    src.dss_record_source AS dss_record_source,

    src.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_start_date,

    1 AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_employee_traders_north') }} AS src

{% endif %}