
{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='hk_h_employee'
) }}

WITH stage AS (

    SELECT
        hk_h_employee,
        extension,
        dss_change_hash_employee_hroc_traders_south AS dss_change_hash,
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

),

final AS (

    SELECT DISTINCT
        s.hk_h_employee,
        s.extension,
        s.dss_change_hash,
        s.dss_record_source,
        s.dss_load_date,

        CURRENT_TIMESTAMP() AS dss_start_date,

        COALESCE(c.dss_version, 0) + 1 AS dss_version,

        CURRENT_TIMESTAMP() AS dss_create_time

    FROM stage s

    LEFT JOIN current_rows c
        ON s.hk_h_employee = c.hk_h_employee

    {% if is_incremental() %}

    WHERE NOT EXISTS (

        SELECT 1
        FROM {{ this }} t

        WHERE s.hk_h_employee = t.hk_h_employee
          AND s.dss_change_hash = t.dss_change_hash
          AND c.dss_start_date = t.dss_start_date

    )

    {% endif %}

)

SELECT *
FROM final