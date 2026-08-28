{{ config(
    materialized='table'
) }}

WITH date_spine AS (

    SELECT
        DATEADD(
            DAY,
            SEQ4(),
            TO_DATE('2020-01-01')
        ) AS calendar_date

    FROM TABLE(
        GENERATOR(
            ROWCOUNT => 3653
        )
    )

),

calendar AS (

    SELECT
        calendar_date,

        YEAR(calendar_date) AS cal_year,

        MONTH(calendar_date) AS cal_month_no,

        MONTHNAME(calendar_date) AS cal_month_name,

        DAY(calendar_date) AS cal_day_in_month,

        DAYOFYEAR(calendar_date) AS cal_day_in_year,

        DAYOFWEEK(calendar_date) AS cal_day_in_week_no,

        DAYNAME(calendar_date) AS cal_day_in_week,

        WEEKOFYEAR(calendar_date) AS cal_week_in_year,

        QUARTER(calendar_date) AS cal_quarter_no

    FROM date_spine

)

SELECT

    /* Date key */

    TO_NUMBER(TO_CHAR(calendar_date, 'YYYYMMDD'))
        AS dim_date_key,

    calendar_date,

    /* Calendar attributes */

    TO_CHAR(calendar_date, 'YYYY-MM')
        AS cal_month,

    cal_month_no,

    cal_year,

    cal_day_in_week,

    cal_day_in_week_no,

    cal_day_in_month,

    cal_day_in_year,

    cal_week_in_year,

    cal_month_name,

    cal_quarter_no,

    'Q' || cal_quarter_no
        AS cal_quarter,

    /* Financial calendar */

    calendar_date
        AS financial_date,

    cal_day_in_week
        AS fin_day_in_week,

    cal_day_in_week_no
        AS fin_day_in_week_no,

    cal_day_in_month
        AS fin_day_in_month,

    cal_day_in_year
        AS fin_day_in_year,

    WEEK(calendar_date)
        AS fin_week_in_month,

    WEEKOFYEAR(calendar_date)
        AS fin_week_in_year,

    cal_month_no
        AS fin_month_no,

    TO_CHAR(calendar_date, 'YYYY-MM')
        AS fin_month,

    cal_month_name
        AS fin_month_name,

    cal_month_no
        AS fin_period,

    cal_quarter_no
        AS fin_quarter_no,

    'Q' || cal_quarter_no
        AS fin_quarter,

    cal_year
        AS fin_year,

    /* Weekend flags */

    CASE
        WHEN DAYOFWEEK(calendar_date) IN (1, 7)
            THEN 'Y'
        ELSE 'N'
    END AS week_day_flag,

    CASE
        WHEN DAYOFWEEK(calendar_date) IN (1, 7)
            THEN 'Y'
        ELSE 'N'
    END AS week_end_flag,

    /* Holiday information */

    NULL AS holiday_desc,

    'N' AS holiday_flag,

    /* Trading day */

    CASE
        WHEN DAYOFWEEK(calendar_date) IN (1, 7)
            THEN 'N'
        ELSE 'Y'
    END AS trading_day_flag,

    NULL AS trading_days_so_far,

    NULL AS trading_days_in_mth,

    CURRENT_TIMESTAMP() AS dss_update_time

FROM calendar
