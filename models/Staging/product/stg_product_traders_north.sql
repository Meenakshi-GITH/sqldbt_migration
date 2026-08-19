SELECT
    MD5(
        COALESCE(CAST(productname AS VARCHAR), 'null')
    ) AS hk_h_product,

    productname AS product_name,

    unitsinstock AS unitsinstock,

    unitsonorder AS unitsonorder,

    productid AS productid,

    reorderlevel AS reorderlevel,

    discontinued AS discontinued,

    supplierid AS supplierid,

    categoryid AS categoryid,

    quantityperunit AS quantityperunit,

    unitprice AS unitprice,

    MD5(
        COALESCE(CAST(unitsinstock AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(unitsonorder AS VARCHAR), 'null')
    ) AS dss_change_hash_product_hroc_traders_north,

    MD5(
        COALESCE(CAST(productid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(reorderlevel AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(discontinued AS VARCHAR), 'null')
    ) AS dss_change_hash_product_lroc_traders_north,

    MD5(
        COALESCE(CAST(supplierid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(categoryid AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(quantityperunit AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(unitprice AS VARCHAR), 'null')
    ) AS dss_change_hash_product_mroc_traders_north,

    dss_record_source AS dss_record_source,

    dss_load_date AS dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('traders_raw', 'load_products_traders_north') }}