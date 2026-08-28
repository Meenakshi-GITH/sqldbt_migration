{{ config(
    materialized='incremental',
    unique_key='hk_l_employee_territories',
    incremental_strategy='append'
) }}

with south as (

    select distinct
        hk_l_employee_territories,
        hk_h_employee,
        hk_h_territory,
        dss_record_source,
        dss_load_date,
        current_timestamp() as dss_create_time
    from {{ ref('stg_employee_territories_traders_south') }}

),

north as (

    select distinct
        hk_l_employee_territories,
        hk_h_employee,
        hk_h_territory,
        dss_record_source,
        dss_load_date,
        current_timestamp() as dss_create_time
    from {{ ref('stg_employee_territories_traders_north') }}

),

all_records as (

    select *
    from south

    union

    select *
    from north

)

select
    hk_l_employee_territories,
    hk_h_employee,
    hk_h_territory,
    dss_record_source,
    dss_load_date,
    dss_create_time

from all_records

{% if is_incremental() %}

where not exists (

    select 1
    from {{ this }} as existing

    where existing.hk_h_employee = all_records.hk_h_employee
      and existing.hk_h_territory = all_records.hk_h_territory

)

{% endif %}