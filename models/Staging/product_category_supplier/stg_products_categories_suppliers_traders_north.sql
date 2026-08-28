WITH products AS (

    SELECT
        productid,
        supplierid,
        categoryid,
        productname,
        dss_record_source,
        dss_load_date
    FROM {{ source('traders_raw', 'load_products_traders_north') }}

),

suppliers AS (

    SELECT
        supplierid,
        companyname,
        dss_record_source,
        dss_load_date
    FROM {{ source('traders_raw', 'load_suppliers_traders_north') }}

),

categories AS (

    SELECT
        categoryid,
        categoryname
    FROM {{ source('traders_raw', 'load_categories_traders_north') }}

)

SELECT

    /* Link hash key */
    MD5(
        COALESCE(CAST(c.categoryname AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(p.productname AS VARCHAR), 'null')
        || '||' ||
        COALESCE(CAST(s.companyname AS VARCHAR), 'null')
    ) AS hk_l_products_categories_suppliers,

    /* Hub hash keys */
    MD5(
        COALESCE(CAST(c.categoryname AS VARCHAR), 'null')
    ) AS hk_h_category,

    MD5(
        COALESCE(CAST(p.productname AS VARCHAR), 'null')
    ) AS hk_h_product,

    MD5(
        COALESCE(CAST(s.companyname AS VARCHAR), 'null')
    ) AS hk_h_supplier,

    /* Descriptive attributes */
    c.categoryname AS category_name,
    p.productname AS product_name,
    s.companyname AS supplier_name,

    /* Metadata */
    s.dss_record_source AS dss_record_source,
    s.dss_load_date AS dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM products p

INNER JOIN suppliers s
    ON p.supplierid = s.supplierid

INNER JOIN categories c
    ON p.categoryid = c.categoryid