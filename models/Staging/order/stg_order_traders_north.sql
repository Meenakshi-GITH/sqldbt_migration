SELECT
    MD5(
        COALESCE(TO_VARCHAR(load_orders_traders_north.orderid), 'null')
    ) AS hk_h_order,

    load_orders_traders_north.orderid AS order_number,
    load_orders_traders_north.freight AS freight,
    load_orders_traders_north.customerid AS customerid,
    load_orders_traders_north.employeeid AS employeeid,
    load_orders_traders_north.shipvia AS shipvia,
    load_orders_traders_north.requireddate AS requireddate,
    load_orders_traders_north.shippeddate AS shippeddate,
    load_orders_traders_north.shipname AS shipname,
    load_orders_traders_north.shipaddress AS shipaddress,
    load_orders_traders_north.shipcity AS shipcity,
    load_orders_traders_north.shipregion AS shipregion,
    load_orders_traders_north.shippostalcode AS shippostalcode,
    load_orders_traders_north.shipcountry AS shipcountry,

    MD5(
        COALESCE(TO_VARCHAR(load_orders_traders_north.freight), 'null')
    ) AS dss_change_hash_order_hroc_traders_north,

    MD5(
        COALESCE(TO_VARCHAR(load_orders_traders_north.customerid), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.employeeid), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shipvia), 'null')
    ) AS dss_change_hash_order_lroc_traders_north,

    MD5(
        COALESCE(TO_VARCHAR(load_orders_traders_north.requireddate), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shippeddate), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shipname), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shipaddress), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shipcity), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shipregion), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shippostalcode), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(load_orders_traders_north.shipcountry), 'null')
    ) AS dss_change_hash_order_mroc_traders_north,

    load_orders_traders_north.dss_record_source,
    load_orders_traders_north.dss_load_date,
    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('traders_raw', 'load_orders_traders_north') }} AS load_orders_traders_north