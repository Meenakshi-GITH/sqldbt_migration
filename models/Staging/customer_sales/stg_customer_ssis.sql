SELECT
    customer_code,
    customer_name,
    customer_category_code,
    customer_group_code,
    customer_subgroup_code,
    sales_source,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ ref('ds_customer_ssis') }}

WHERE TO_DATE('{{ var("ds_customer_process_date") }}')
      BETWEEN TO_DATE(dss_start_date)
      AND TO_DATE(dss_end_date)
