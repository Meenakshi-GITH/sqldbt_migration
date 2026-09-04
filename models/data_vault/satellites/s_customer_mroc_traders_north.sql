{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'append'
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

cte_north AS (

    SELECT DISTINCT
        stage_customer_traders_north.hk_h_customer
            AS hk_h_customer,
        stage_customer_traders_north.country
            AS country,
        stage_customer_traders_north.contactname
            AS contactname,
        stage_customer_traders_north.contacttitle
            AS contacttitle,
        stage_customer_traders_north.address
            AS address,
        stage_customer_traders_north.city
            AS city,
        stage_customer_traders_north.region
            AS region,
        stage_customer_traders_north.postalcode
            AS postalcode,
        stage_customer_traders_north.phone
            AS phone,
        stage_customer_traders_north.fax
            AS fax,
        stage_customer_traders_north.dss_change_hash_customer_mroc_traders_north
            AS dss_change_hash,
        stage_customer_traders_north.dss_record_source
            AS dss_record_source,
        stage_customer_traders_north.dss_load_date
            AS dss_load_date,
        CURRENT_TIMESTAMP()
            AS dss_start_date,
        COALESCE(current_rows.dss_version, 0) + 1
            AS dss_version,
        CURRENT_TIMESTAMP()
            AS dss_create_time

    FROM {{ ref('stg_customer_traders_north') }}
        AS stage_customer_traders_north

    LEFT JOIN current_rows
        ON stage_customer_traders_north.hk_h_customer =
           current_rows.hk_h_customer

    WHERE NOT EXISTS (

        SELECT 1
        FROM {{ this }} AS s_customer_mroc_traders_north

        WHERE stage_customer_traders_north.hk_h_customer =
              s_customer_mroc_traders_north.hk_h_customer

          AND stage_customer_traders_north.dss_change_hash_customer_mroc_traders_north =
              s_customer_mroc_traders_north.dss_change_hash

          AND current_rows.dss_start_date =
              s_customer_mroc_traders_north.dss_start_date

    )

)

SELECT
    hk_h_customer,
    country,
    contactname,
    contacttitle,
    address,
    city,
    region,
    postalcode,
    phone,
    fax,
    dss_change_hash,
    dss_record_source,
    dss_load_date,
    dss_start_date,
    dss_version,
    dss_create_time
FROM cte_north