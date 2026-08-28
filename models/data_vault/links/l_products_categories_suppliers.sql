{{ config(
    materialized='incremental',
    unique_key=[
        'hk_h_category',
        'hk_h_product',
        'hk_h_supplier'
    ],
    incremental_strategy='merge'
) }}

WITH combined_stage AS (

    /* South */
    SELECT
        hk_l_products_categories_suppliers,
        hk_h_category,
        hk_h_product,
        hk_h_supplier,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stg_products_categories_suppliers_traders_south') }}

    UNION ALL

    /* North */
    SELECT
        hk_l_products_categories_suppliers,
        hk_h_category,
        hk_h_product,
        hk_h_supplier,
        dss_record_source,
        dss_load_date
    FROM {{ ref('stg_products_categories_suppliers_traders_north') }}

),

deduplicated AS (

    SELECT DISTINCT
        hk_l_products_categories_suppliers,
        hk_h_category,
        hk_h_product,
        hk_h_supplier,
        dss_record_source,
        dss_load_date
    FROM combined_stage

)

SELECT
    hk_l_products_categories_suppliers,
    hk_h_category,
    hk_h_product,
    hk_h_supplier,
    dss_record_source,
    dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM deduplicated

{% if is_incremental() %}

WHERE NOT EXISTS (

    SELECT 1
    FROM {{ this }} existing

    WHERE existing.hk_h_category = deduplicated.hk_h_category
      AND existing.hk_h_product  = deduplicated.hk_h_product
      AND existing.hk_h_supplier = deduplicated.hk_h_supplier

)

{% endif %}