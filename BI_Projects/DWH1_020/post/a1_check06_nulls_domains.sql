SET search_path TO dwh_020;

SELECT
  SUM(CASE WHEN day_id IS NULL THEN 1 ELSE 0 END) AS null_day_fk,
  SUM(CASE WHEN sk_device_geo IS NULL THEN 1 ELSE 0 END) AS null_device_fk,
  SUM(CASE WHEN recorded_value IS NULL THEN 1 ELSE 0 END) AS null_measure,
  'OK' AS status_check,
  CURRENT_TIMESTAMP AS run_time
FROM ft_reading;
