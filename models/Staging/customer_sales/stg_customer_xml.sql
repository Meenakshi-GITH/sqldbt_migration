SELECT
    code AS customer_code,
    name AS customer_name,
    cat_code AS customer_category_code,
    grp_code AS customer_group_code,
    subgrp AS customer_subgroup_code,
    source_sales AS sales_source,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ ref('ds_customer_xml') }}

WHERE TO_DATE('{{ var("ds_customer_process_date") }}')
      BETWEEN TO_DATE(dss_start_date)
      AND TO_DATE(dss_end_date)
