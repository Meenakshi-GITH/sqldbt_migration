{{ config(
    materialized = 'incremental',
    incremental_strategy = 'append'
) }}

WITH cte_south AS (

    SELECT DISTINCT
        stage_product_traders_south.hk_h_product AS hk_h_product,
        stage_product_traders_south.product_name AS product_name,
        stage_product_traders_south.dss_record_source AS dss_record_source,
        stage_product_traders_south.dss_load_date AS dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM {{ ref('stg_product_traders_south') }} AS stage_product_traders_south

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} AS h_product
        WHERE stage_product_traders_south.product_name = h_product.product_name
    )

    {% endif %}
),

cte_north AS (

    SELECT DISTINCT
        stage_product_traders_north.hk_h_product AS hk_h_product,
        stage_product_traders_north.product_name AS product_name,
        stage_product_traders_north.dss_record_source AS dss_record_source,
        stage_product_traders_north.dss_load_date AS dss_load_date,
        CURRENT_TIMESTAMP() AS dss_create_time

    FROM {{ ref('stg_product_traders_north') }} AS stage_product_traders_north

    {% if is_incremental() %}

    WHERE NOT EXISTS (
        SELECT 1
        FROM {{ this }} AS h_product
        WHERE stage_product_traders_north.product_name = h_product.product_name
    )

    {% endif %}
)

SELECT
    hk_h_product,
    product_name,
    dss_record_source,
    dss_load_date,
    dss_create_time
FROM cte_south

UNION ALL

SELECT
    hk_h_product,
    product_name,
    dss_record_source,
    dss_load_date,
    dss_create_time
FROM cte_north