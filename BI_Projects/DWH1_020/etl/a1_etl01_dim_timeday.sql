-- Make A1 dwh_020, stg_020 schemas the default for this session
SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_timeday
-- =======================================

TRUNCATE TABLE dim_timeday RESTART IDENTITY CASCADE;

-- Generate continuous dates between min(reading/service) and max
INSERT INTO dim_timeday (id, date, year, quarter, month, week, day_of_month, day_of_week, is_weekend)
SELECT
  TO_CHAR(d, 'YYYYMMDD')::INT AS id,
  d::date AS date,
  EXTRACT(YEAR FROM d)::INT AS year,
  EXTRACT(QUARTER FROM d)::INT AS quarter,
  EXTRACT(MONTH FROM d)::INT AS month,
  EXTRACT(WEEK FROM d)::INT AS week,
  EXTRACT(DAY FROM d)::INT AS day_of_month,
  EXTRACT(DOW FROM d)::INT AS day_of_week,
  (EXTRACT(DOW FROM d)::INT IN (0,6)) AS is_weekend
FROM generate_series(
  (SELECT LEAST(MIN(readat), MIN(servicedat)) FROM tb_readingevent CROSS JOIN tb_serviceevent),
  (SELECT GREATEST(MAX(readat), MAX(servicedat)) FROM tb_readingevent CROSS JOIN tb_serviceevent),
  INTERVAL '1 day'
) g(d)
ORDER BY 1;
