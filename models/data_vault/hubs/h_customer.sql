{{ config(
    materialized = 'incremental',
    database = 'TRADERS_DB',
    schema = 'HUB',
    alias = 'H_CUSTOMER',
    incremental_strategy = 'append'
) }}

WITH cte_south AS (

    SELECT DISTINCT
        stage_customer_traders_south.hk_h_customer AS hk_h_customer,
        stage_customer_traders_south.customer_name AS customer_name,
        stage_customer_traders_south.dss_record_source AS dss_record_source,
        stage_customer_traders_south.dss_load_date AS dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM {{ ref('stg_customer_traders_south') }} AS stage_customer_traders_south

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} AS h_customer
        WHERE stage_customer_traders_south.customer_name = h_customer.customer_name
    )

    {% endif %}
),

cte_north AS (

    SELECT DISTINCT
        stage_customer_traders_north.hk_h_customer AS hk_h_customer,
        stage_customer_traders_north.customer_name AS customer_name,
        stage_customer_traders_north.dss_record_source AS dss_record_source,
        stage_customer_traders_north.dss_load_date AS dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM {{ ref('stg_customer_traders_north') }} AS stage_customer_traders_north

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} AS h_customer
        WHERE stage_customer_traders_north.customer_name = h_customer.customer_name
    )

    {% endif %}
)

SELECT
    hk_h_customer,
    customer_name,
    dss_record_source,
    dss_load_date,
    dss_create_time
FROM cte_south

UNION ALL

SELECT
    hk_h_customer,
    customer_name,
    dss_record_source,
    dss_load_date,
    dss_create_time
FROM cte_north