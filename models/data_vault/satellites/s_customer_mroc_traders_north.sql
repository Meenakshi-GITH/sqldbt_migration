{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

{% if is_incremental() %}

WITH current_rows AS (

    SELECT
        hk_h_customer,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version
    FROM {{ this }}
    GROUP BY hk_h_customer

)

SELECT DISTINCT
    src.hk_h_customer AS hk_h_customer,
    src.country AS country,
    src.contactname AS contactname,
    src.contacttitle AS contacttitle,
    src.address AS address,
    src.city AS city,
    src.region AS region,
    src.postalcode AS postalcode,
    src.phone AS phone,
    src.fax AS fax,
    src.dss_change_hash_customer_mroc_traders_north AS dss_change_hash,
    src.dss_record_source AS dss_record_source,
    src.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    COALESCE(current_rows.dss_version, 0) + 1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_customer_traders_north') }} AS src

LEFT JOIN current_rows
    ON src.hk_h_customer = current_rows.hk_h_customer

WHERE NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS target
    WHERE src.hk_h_customer = target.hk_h_customer
      AND src.dss_change_hash_customer_mroc_traders_north =
          target.dss_change_hash
      AND current_rows.dss_start_date =
          target.dss_start_date
)

{% else %}

SELECT DISTINCT
    src.hk_h_customer AS hk_h_customer,
    src.country AS country,
    src.contactname AS contactname,
    src.contacttitle AS contacttitle,
    src.address AS address,
    src.city AS city,
    src.region AS region,
    src.postalcode AS postalcode,
    src.phone AS phone,
    src.fax AS fax,
    src.dss_change_hash_customer_mroc_traders_north AS dss_change_hash,
    src.dss_record_source AS dss_record_source,
    src.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_start_date,
    1 AS dss_version,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ ref('stg_customer_traders_north') }} AS src

{% endif %}