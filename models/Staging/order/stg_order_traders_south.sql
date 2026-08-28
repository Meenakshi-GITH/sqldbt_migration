SELECT
    MD5(
        COALESCE(TO_VARCHAR(orderid), 'null')
    ) AS hk_h_order,

    orderid AS order_number,

    freight,

    customerid,

    employeeid,

    shipvia,

    requireddate,

    shippeddate,

    shipname,

    shipaddress,

    shipcity,

    shipregion,

    shippostalcode,

    shipcountry,

    MD5(
        COALESCE(TO_VARCHAR(freight), 'null')
    ) AS dss_change_hash_order_hroc_traders_south,

    MD5(
        COALESCE(TO_VARCHAR(customerid), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(employeeid), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shipvia), 'null')
    ) AS dss_change_hash_order_lroc_traders_south,

    MD5(
        COALESCE(TO_VARCHAR(requireddate), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shippeddate), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shipname), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shipaddress), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shipcity), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shipregion), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shippostalcode), 'null')
        || '||' ||
        COALESCE(TO_VARCHAR(shipcountry), 'null')
    ) AS dss_change_hash_order_mroc_traders_south,

    dss_record_source,

    dss_load_date,

    CURRENT_TIMESTAMP() AS dss_create_time

FROM {{ source('traders_raw', 'load_orders_traders_south') }}