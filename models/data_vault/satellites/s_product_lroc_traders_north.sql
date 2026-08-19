{{ config(
    materialized='incremental'
) }}

SELECT DISTINCT

    h_product.hk_h_product AS hk_h_product,

    stage_product_traders_north.productid AS productid,

    stage_product_traders_north.reorderlevel AS reorderlevel,

    stage_product_traders_north.discontinued AS discontinued,

    stage_product_traders_north.dss_change_hash_product_lroc_traders_north
        AS dss_change_hash,

    stage_product_traders_north.dss_record_source
        AS dss_record_source,

    stage_product_traders_north.dss_load_date
        AS dss_load_date,

    CURRENT_TIMESTAMP()
        AS dss_start_date,

    {% if is_incremental() %}
        COALESCE(current_rows.dss_version, 0) + 1
    {% else %}
        1
    {% endif %}
        AS dss_version,

    CURRENT_TIMESTAMP()
        AS dss_create_time

FROM {{ ref('h_product') }} AS h_product

INNER JOIN {{ ref('stg_product_traders_north') }} AS stage_product_traders_north

    ON h_product.hk_h_product =
       stage_product_traders_north.hk_h_product

{% if is_incremental() %}

LEFT JOIN (

    SELECT
        hk_h_product,
        MAX(dss_start_date) AS dss_start_date,
        MAX(dss_version) AS dss_version

    FROM {{ this }}

    GROUP BY hk_h_product

) AS current_rows

    ON h_product.hk_h_product =
       current_rows.hk_h_product

WHERE NOT EXISTS (

    SELECT 1

    FROM {{ this }} AS s_product_lroc_traders_north

    WHERE h_product.hk_h_product =
          s_product_lroc_traders_north.hk_h_product

      AND stage_product_traders_north.dss_change_hash_product_lroc_traders_north =
          s_product_lroc_traders_north.dss_change_hash

      AND current_rows.dss_start_date =
          s_product_lroc_traders_north.dss_start_date

)

{% endif %}