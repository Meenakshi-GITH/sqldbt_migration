{{ config(
    materialized='view'
) }}

SELECT

    MD5(
        COALESCE(
            CAST(load_employees_traders_south.employeeid AS VARCHAR),
            'null'
        )
    ) AS hk_h_employee,

    load_employees_traders_south.employeeid AS employee_id,

    load_employees_traders_south.country AS country,

    load_employees_traders_south.lastname AS lastname,

    load_employees_traders_south.firstname AS firstname,

    load_employees_traders_south.title AS title,

    load_employees_traders_south.titleofcourtesy AS titleofcourtesy,

    load_employees_traders_south.birthdate AS birthdate,

    load_employees_traders_south.address AS address,

    load_employees_traders_south.city AS city,

    load_employees_traders_south.region AS region,

    load_employees_traders_south.postalcode AS postalcode,

    load_employees_traders_south.homephone AS homephone,

    load_employees_traders_south.reportsto AS reportsto,

    load_employees_traders_south.extension AS extension,

    load_employees_traders_south.hiredate AS hiredate,

    MD5(
        COALESCE(CAST(load_employees_traders_south.country AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.lastname AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.firstname AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.title AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.titleofcourtesy AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.birthdate AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.address AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.city AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.region AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.postalcode AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.homephone AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_south.reportsto AS VARCHAR), 'null')
    ) AS dss_change_hash_employee_gdpr_traders_south,

    MD5(
        COALESCE(
            CAST(load_employees_traders_south.extension AS VARCHAR),
            'null'
        )
    ) AS dss_change_hash_employee_hroc_traders_south,

    MD5(
        COALESCE(
            CAST(load_employees_traders_south.hiredate AS VARCHAR),
            'null'
        )
    ) AS dss_change_hash_employee_lroc_traders_south,

    load_employees_traders_south.dss_record_source AS dss_record_source,

    load_employees_traders_south.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('traders_raw', 'load_employees_traders_south') }}
    AS load_employees_traders_south