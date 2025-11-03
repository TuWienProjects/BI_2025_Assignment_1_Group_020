SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_timeday (auto-extended version)
-- =======================================

TRUNCATE TABLE dim_timeday RESTART IDENTITY CASCADE;

WITH bounds AS (
    SELECT
        LEAST(
            (SELECT MIN(readat)      FROM tb_readingevent),
            (SELECT MIN(servicedat)  FROM tb_serviceevent),
            (SELECT MIN(observedat)  FROM tb_weather),
            (SELECT MIN(start_date)  FROM tb_campaign)
        ) AS min_date,
        GREATEST(
            -- ensure we cover all real data + a buffer year ahead
            GREATEST(
                (SELECT MAX(readat)      FROM tb_readingevent),
                (SELECT MAX(servicedat)  FROM tb_serviceevent),
                (SELECT MAX(observedat)  FROM tb_weather),
                (SELECT MAX(COALESCE(end_date, CURRENT_DATE)) FROM tb_campaign)
            ),
            CURRENT_DATE + INTERVAL '365 day'
        ) AS max_date
)
INSERT INTO dim_timeday (
    id, date, year, quarter, month, week, day_of_month, day_of_week, is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT AS id,
    d::date                    AS date,
    EXTRACT(YEAR FROM d)::INT    AS year,
    EXTRACT(QUARTER FROM d)::INT AS quarter,
    EXTRACT(MONTH FROM d)::INT   AS month,
    EXTRACT(WEEK FROM d)::INT    AS week,
    EXTRACT(DAY FROM d)::INT     AS day_of_month,
    EXTRACT(DOW FROM d)::INT     AS day_of_week,
    (EXTRACT(DOW FROM d)::INT IN (0,6)) AS is_weekend
FROM bounds b,
     generate_series(b.min_date, b.max_date, INTERVAL '1 day') AS g(d)
ORDER BY 1;
