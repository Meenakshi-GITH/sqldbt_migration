SELECT
    customer_code,
    customer_name,
    customer_legal_name,
    territory_id,
    ship_to_address_id,
    bill_to_address_id,
    sold_to_address_id,
    primary_address_type,
    primary_contact_person,
    active_flag,

    customer_category_code,
    customer_category_description,

    customer_group_code,
    customer_group_description,

    customer_subgroup_code,
    customer_subgroup_description,

    creating_employee_id,
    created_datetime,

    last_change_employee_id,
    last_change_datetime,

    CURRENT_TIMESTAMP() AS dss_start_date,

    TO_TIMESTAMP_NTZ('2999-12-31 23:59:59')
        AS dss_end_date,

    'Y' AS dss_current_flag,

    dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM {{ source('traders_raw', 'load_customer_sales2') }}