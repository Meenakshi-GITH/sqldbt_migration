SELECT
    customer_code,
    customer_name,
    customer_category_code,
    customer_group_code,
    customer_subgroup_code,

    3 AS sales_source,

    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ ref('ds_customer_sales2') }}

WHERE TO_DATE('{{ var("ds_customer_process_date", "2026-08-27") }}')
      BETWEEN TO_DATE(dss_start_date)
      AND TO_DATE(dss_end_date)