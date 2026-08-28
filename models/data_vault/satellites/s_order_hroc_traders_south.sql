{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with stage_order as (

    select distinct
        hk_h_order,
        freight,
        dss_change_hash_order_hroc_traders_south,
        dss_record_source,
        dss_load_date
    from {{ ref('stg_order_traders_south') }}

),

{% if is_incremental() %}

current_rows as (

    select
        hk_h_order,
        max(dss_start_date) as dss_start_date,
        max(dss_version) as dss_version
    from {{ this }}
    group by hk_h_order

)

{% else %}

current_rows as (

    select
        cast(null as varchar) as hk_h_order,
        cast(null as timestamp) as dss_start_date,
        cast(null as integer) as dss_version
    where false

)

{% endif %}

select distinct
    stage_order.hk_h_order as hk_h_order,
    stage_order.freight as freight,
    stage_order.dss_change_hash_order_hroc_traders_south as dss_change_hash,
    stage_order.dss_record_source as dss_record_source,
    stage_order.dss_load_date as dss_load_date,
    current_timestamp() as dss_start_date,
    coalesce(current_rows.dss_version, 0) + 1 as dss_version,
    current_timestamp() as dss_create_time

from stage_order

left join current_rows
    on stage_order.hk_h_order = current_rows.hk_h_order

{% if is_incremental() %}

where not exists (

    select 1
    from {{ this }} as target

    where stage_order.hk_h_order = target.hk_h_order
      and stage_order.dss_change_hash_order_hroc_traders_south =
          target.dss_change_hash
      and current_rows.dss_start_date = target.dss_start_date

)

{% endif %}