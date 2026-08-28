WITH source_data AS (

    SELECT
        customer_code,
        customer_name,
        customer_legal_name,
        territory_id,
        ship_to_address_id,
        sales_source,
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
        last_change_datetime
    FROM {{ source('traders_raw', 'load_customer_ssis') }}

),

current_data AS (

    {% if is_incremental() %}

    SELECT
        customer_code,
        customer_name,
        customer_legal_name,
        territory_id,
        ship_to_address_id,
        sales_source,
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
        dss_version
    FROM {{ this }}
    WHERE dss_current_flag = 'Y'

    {% else %}

    SELECT
        customer_code,
        customer_name,
        customer_legal_name,
        territory_id,
        ship_to_address_id,
        sales_source,
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
        dss_version
    FROM {{ source('traders_raw', 'load_customer_ssis') }}
    WHERE 1 = 0

    {% endif %}

),

changes AS (

    SELECT
        s.customer_code,
        s.customer_name,
        s.customer_legal_name,
        s.territory_id,
        s.ship_to_address_id,
        s.sales_source,
        s.sold_to_address_id,
        s.primary_address_type,
        s.primary_contact_person,
        s.active_flag,
        s.customer_category_code,
        s.customer_category_description,
        s.customer_group_code,
        s.customer_group_description,
        s.customer_subgroup_code,
        s.customer_subgroup_description,
        s.creating_employee_id,
        s.created_datetime,
        s.last_change_employee_id,
        s.last_change_datetime,
        c.dss_version

    FROM source_data s

    LEFT JOIN current_data c
        ON s.customer_code = c.customer_code

    WHERE
        c.customer_code IS NULL

        OR NVL(s.customer_name, '') != NVL(c.customer_name, '')
        OR NVL(s.customer_legal_name, '') != NVL(c.customer_legal_name, '')
        OR NVL(s.territory_id, -1) != NVL(c.territory_id, -1)
        OR NVL(s.ship_to_address_id, -1) != NVL(c.ship_to_address_id, -1)
        OR NVL(s.sales_source, -1) != NVL(c.sales_source, -1)
        OR NVL(s.sold_to_address_id, -1) != NVL(c.sold_to_address_id, -1)
        OR NVL(s.primary_address_type, '') != NVL(c.primary_address_type, '')
        OR NVL(s.primary_contact_person, '') != NVL(c.primary_contact_person, '')
        OR NVL(s.active_flag, '') != NVL(c.active_flag, '')
        OR NVL(s.customer_category_code, '') != NVL(c.customer_category_code, '')
        OR NVL(s.customer_category_description, '') != NVL(c.customer_category_description, '')
        OR NVL(s.customer_group_code, '') != NVL(c.customer_group_code, '')
        OR NVL(s.customer_group_description, '') != NVL(c.customer_group_description, '')
        OR NVL(s.customer_subgroup_code, '') != NVL(c.customer_subgroup_code, '')
        OR NVL(s.customer_subgroup_description, '') != NVL(c.customer_subgroup_description, '')
        OR NVL(s.creating_employee_id, -1) != NVL(c.creating_employee_id, -1)
        OR NVL(s.created_datetime, TO_TIMESTAMP_NTZ('1900-01-01')) !=
           NVL(c.created_datetime, TO_TIMESTAMP_NTZ('1900-01-01'))
        OR NVL(s.last_change_employee_id, -1) != NVL(c.last_change_employee_id, -1)
        OR NVL(s.last_change_datetime, TO_TIMESTAMP_NTZ('1900-01-01')) !=
           NVL(c.last_change_datetime, TO_TIMESTAMP_NTZ('1900-01-01'))

)

SELECT
    customer_code,
    customer_name,
    customer_legal_name,
    territory_id,
    ship_to_address_id,
    sales_source,
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

    CASE
        WHEN dss_version IS NULL
            THEN TO_TIMESTAMP_NTZ('1900-01-01 00:00:00')
        ELSE CURRENT_TIMESTAMP()
    END AS dss_start_date,

    TO_TIMESTAMP_NTZ('2999-12-31 23:59:59') AS dss_end_date,

    'Y' AS dss_current_flag,

    CASE
        WHEN dss_version IS NULL
            THEN 1
        ELSE dss_version + 1
    END AS dss_version,

    CURRENT_TIMESTAMP() AS dss_create_time,
    CURRENT_TIMESTAMP() AS dss_update_time

FROM changes