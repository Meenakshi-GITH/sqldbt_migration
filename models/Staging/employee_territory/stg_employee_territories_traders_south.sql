select

    md5(
        coalesce(cast(employeeid as varchar), 'null')
        || '||' ||
        coalesce(cast(territoryid as varchar), 'null')
    ) as hk_l_employee_territories,

    md5(
        coalesce(cast(employeeid as varchar), 'null')
    ) as hk_h_employee,

    md5(
        coalesce(cast(territoryid as varchar), 'null')
    ) as hk_h_territory,

    employeeid as employee_id,

    territoryid as territory_id,

    dss_record_source,

    dss_load_date,

    current_timestamp() as dss_create_time

from {{ source(
    'traders_raw',
    'load_employeeterritories_traders_south'
) }}