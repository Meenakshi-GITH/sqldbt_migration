SELECT
    MD5(
        COALESCE(CAST(COMPANYNAME AS VARCHAR), 'null')
    ) AS HK_H_CUSTOMER,

    COMPANYNAME AS CUSTOMER_NAME,
    CUSTOMERID,
    COUNTRY,
    CONTACTNAME,
    CONTACTTITLE,
    ADDRESS,
    CITY,
    REGION,
    POSTALCODE,
    PHONE,
    FAX,

    MD5(
        COALESCE(CAST(CUSTOMERID AS VARCHAR), 'null')
    ) AS DSS_CHANGE_HASH_CUSTOMER_LROC_TRADERS_NORTH,

    MD5(
        COALESCE(CAST(COUNTRY AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(CONTACTNAME AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(CONTACTTITLE AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(ADDRESS AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(CITY AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(REGION AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(POSTALCODE AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(PHONE AS VARCHAR), 'null') || '||' ||
        COALESCE(CAST(FAX AS VARCHAR), 'null')
    ) AS DSS_CHANGE_HASH_CUSTOMER_MROC_TRADERS_NORTH,

    DSS_RECORD_SOURCE,
    DSS_LOAD_DATE,
    CURRENT_TIMESTAMP() AS DSS_CREATE_TIME

FROM {{ source('traders_raw', 'load_customers_traders_north') }}