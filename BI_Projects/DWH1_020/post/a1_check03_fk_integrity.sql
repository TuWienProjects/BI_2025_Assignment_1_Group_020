SET search_path TO dwh_020;

SELECT
  SUM(CASE WHEN sk_device_geo IS NULL THEN 1 ELSE 0 END) AS invalid_device_geo,
  SUM(CASE WHEN sk_parameter IS NULL THEN 1 ELSE 0 END) AS invalid_param,
  SUM(CASE WHEN sk_readingmode IS NULL THEN 1 ELSE 0 END) AS invalid_mode,
  'OK' AS status_check,
  CURRENT_TIMESTAMP AS run_time
FROM ft_reading;
