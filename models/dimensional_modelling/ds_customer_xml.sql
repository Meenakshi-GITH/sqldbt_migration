{{ config(
    unique_key='code'
) }}

WITH source_data AS (

    SELECT
        code,
        name,
        cat_code,
        grp_code,
        subgrp,
        source_sales
    FROM {{ source('traders_raw', 'load_customer_xml') }}

),

version_data AS (

    {% if is_incremental() %}

    SELECT
        code,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY code

    {% else %}

    SELECT
        CAST(NULL AS VARCHAR) AS code,
        CAST(NULL AS NUMBER) AS dss_version
    WHERE 1 = 0

    {% endif %}

),

changes AS (

    SELECT
        s.code,
        s.name,
        s.cat_code,
        s.grp_code,
        s.subgrp,
        s.source_sales,
        v.dss_version

    FROM source_data s

    LEFT JOIN version_data v
        ON s.code = v.code

)

SELECT

    code,
    name,
    cat_code,
    grp_code,
    subgrp,
    source_sales,

    CASE
        WHEN dss_version IS NULL
            THEN TO_TIMESTAMP_NTZ('1900-01-01 00:00:00')
        ELSE CURRENT_TIMESTAMP()
    END AS dss_start_date,

    TO_TIMESTAMP_NTZ('2999-12-31 23:59:59')
        AS dss_end_date,

    'Y' AS dss_current_flag,

    CASE
        WHEN dss_version IS NULL
            THEN 1
        ELSE dss_version + 1
    END AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM changes