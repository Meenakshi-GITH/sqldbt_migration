{{ config(
    materialized = 'incremental',
    incremental_strategy = 'append'
) }}

WITH cte_south AS (

    SELECT DISTINCT
        stage_order_traders_south.hk_h_order AS hk_h_order,
        stage_order_traders_south.order_number AS order_number,
        stage_order_traders_south.dss_record_source AS dss_record_source,
        stage_order_traders_south.dss_load_date AS dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM {{ ref('stg_order_traders_south') }} AS stage_order_traders_south

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} AS h_order
        WHERE stage_order_traders_south.order_number = h_order.order_number
    )

    {% endif %}
),

cte_north AS (

    SELECT DISTINCT
        stage_order_traders_north.hk_h_order AS hk_h_order,
        stage_order_traders_north.order_number AS order_number,
        stage_order_traders_north.dss_record_source AS dss_record_source,
        stage_order_traders_north.dss_load_date AS dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM {{ ref('stg_order_traders_north') }} AS stage_order_traders_north

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} AS h_order
        WHERE stage_order_traders_north.order_number = h_order.order_number
    )

    {% endif %}
)

SELECT
    hk_h_order,
    order_number,
    dss_record_source,
    dss_load_date,
    dss_create_time
FROM cte_south

UNION ALL

SELECT
    hk_h_order,
    order_number,
    dss_record_source,
    dss_load_date,
    dss_create_time
FROM cte_north