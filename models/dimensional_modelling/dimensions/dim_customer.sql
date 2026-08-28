{{ config(
    unique_key=['customer_code', 'sales_source'],
    on_schema_change='sync_all_columns'
) }}

WITH source_data AS (

    SELECT
        customer_code,
        customer_name,
        customer_category_code,
        customer_group_code,
        customer_subgroup_code,
        sales_source,
        dss_create_time,
        dss_update_time
    FROM {{ ref('stg_customer_mrg') }}

),

current_dimension AS (

    {% if is_incremental() %}

    SELECT
        customer_code,
        sales_source,
        customer_name,
        customer_category_code,
        customer_group_code,
        customer_subgroup_code,
        dss_version
    FROM {{ this }}
    WHERE dss_current_flag = 'Y'

    {% else %}

    SELECT
        NULL AS customer_code,
        NULL AS sales_source,
        NULL AS customer_name,
        NULL AS customer_category_code,
        NULL AS customer_group_code,
        NULL AS customer_subgroup_code,
        NULL AS dss_version
    WHERE FALSE

    {% endif %}

),

changes AS (

    SELECT
        s.customer_code,
        s.customer_name,
        s.customer_category_code,
        s.customer_group_code,
        s.customer_subgroup_code,
        s.sales_source,
        s.dss_create_time,
        s.dss_update_time,

        COALESCE(d.dss_version, 0) AS previous_version

    FROM source_data s

    LEFT JOIN current_dimension d
        ON s.customer_code = d.customer_code
        AND s.sales_source = d.sales_source

    {% if is_incremental() %}

    WHERE d.customer_code IS NULL

       OR NVL(s.customer_name, '') <> NVL(d.customer_name, '')
       OR NVL(s.customer_category_code, '') <> NVL(d.customer_category_code, '')
       OR NVL(s.customer_group_code, '') <> NVL(d.customer_group_code, '')
       OR NVL(s.customer_subgroup_code, '') <> NVL(d.customer_subgroup_code, '')

    {% endif %}

)

SELECT
    customer_code,
    customer_name,
    customer_category_code,
    customer_group_code,
    customer_subgroup_code,
    sales_source,

    CASE
        WHEN previous_version = 0
            THEN TO_TIMESTAMP('1900-01-01')
        ELSE CURRENT_TIMESTAMP()
    END AS dss_start_date,

    TO_TIMESTAMP('2999-12-31') AS dss_end_date,

    'Y' AS dss_current_flag,

    CASE
        WHEN previous_version = 0
            THEN 1
        ELSE previous_version + 1
    END AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM changes

