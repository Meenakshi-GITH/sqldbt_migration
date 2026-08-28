SELECT
    customer_code,
    customer_name,
    customer_category_code,
    customer_group_code,
    customer_subgroup_code,
    sales_source,
    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ ref('stg_customer_xml') }}

UNION ALL

SELECT
    customer_code,
    customer_name,
    customer_category_code,
    customer_group_code,
    customer_subgroup_code,
    sales_source,
    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ ref('stg_customer_sales2') }}

UNION ALL

SELECT
    customer_code,
    customer_name,
    customer_category_code,
    customer_group_code,
    customer_subgroup_code,
    sales_source,
    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ ref('stg_customer_ssis') }}