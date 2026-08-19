{{ config(
    materialized='incremental'
) }}

WITH stage_customer AS (

    SELECT
        hk_h_customer,
        customerid,
        dss_change_hash_customer_lroc_traders_south,
        dss_record_source,
        dss_load_date

    FROM {{ ref('stg_customer_traders_south') }}

),

hub_customer AS (

    SELECT
        hk_h_customer

    FROM {{ ref('h_customer') }}

),

{% if is_incremental() %}

current_rows AS (

    SELECT
        hk_h_customer,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_customer

),

{% endif %}

new_records AS (

    SELECT DISTINCT

        stage_customer.hk_h_customer,
        stage_customer.customerid,

        stage_customer.dss_change_hash_customer_lroc_traders_south
            AS dss_change_hash,

        stage_customer.dss_record_source,
        stage_customer.dss_load_date,

        CURRENT_TIMESTAMP() AS dss_start_date,

        {% if is_incremental() %}
        COALESCE(current_rows.dss_version, 0) + 1
        {% else %}
        1
        {% endif %} AS dss_version,

        CURRENT_TIMESTAMP() AS dss_create_time

    FROM stage_customer

    INNER JOIN hub_customer
        ON stage_customer.hk_h_customer = hub_customer.hk_h_customer

    {% if is_incremental() %}

    LEFT JOIN current_rows
        ON stage_customer.hk_h_customer = current_rows.hk_h_customer

    WHERE NOT EXISTS (

        SELECT 1

        FROM {{ this }} AS existing_satellite

        WHERE stage_customer.hk_h_customer =
              existing_satellite.hk_h_customer

          AND stage_customer.dss_change_hash_customer_lroc_traders_south =
              existing_satellite.dss_change_hash

          AND current_rows.dss_start_date =
              existing_satellite.dss_start_date

    )

    {% endif %}

)

SELECT *

FROM new_records