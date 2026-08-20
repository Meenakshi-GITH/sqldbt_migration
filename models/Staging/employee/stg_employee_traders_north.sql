{{ config(
    materialized='view'
) }}

SELECT

    MD5(
        COALESCE(CAST(load_employees_traders_north.employeeid AS VARCHAR), 'null')
    ) AS hk_h_employee,

    load_employees_traders_north.employeeid AS employee_id,
    load_employees_traders_north.country AS country,
    load_employees_traders_north.lastname AS lastname,
    load_employees_traders_north.firstname AS firstname,
    load_employees_traders_north.title AS title,
    load_employees_traders_north.titleofcourtesy AS titleofcourtesy,
    load_employees_traders_north.birthdate AS birthdate,
    load_employees_traders_north.address AS address,
    load_employees_traders_north.city AS city,
    load_employees_traders_north.region AS region,
    load_employees_traders_north.postalcode AS postalcode,
    load_employees_traders_north.homephone AS homephone,
    load_employees_traders_north.reportsto AS reportsto,
    load_employees_traders_north.extension AS extension,
    load_employees_traders_north.hiredate AS hiredate,

    MD5(
        COALESCE(CAST(load_employees_traders_north.country AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.lastname AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.firstname AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.title AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.titleofcourtesy AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.birthdate AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.address AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.city AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.region AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.postalcode AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.homephone AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(load_employees_traders_north.reportsto AS VARCHAR), 'null')
    ) AS dss_change_hash_employee_gdpr_traders_north,

    MD5(
        COALESCE(
            CAST(load_employees_traders_north.extension AS VARCHAR),
            'null'
        )
    ) AS dss_change_hash_employee_hroc_traders_north,

    MD5(
        COALESCE(
            CAST(load_employees_traders_north.hiredate AS VARCHAR),
            'null'
        )
    ) AS dss_change_hash_employee_lroc_traders_north,

    load_employees_traders_north.dss_record_source AS dss_record_source,
    load_employees_traders_north.dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('traders_raw', 'load_employees_traders_north') }}
    AS load_employees_traders_north