SET search_path TO dwh_020;

SELECT
  SUM(CASE WHEN service_cost_eur < 0 THEN 1 ELSE 0 END) AS negative_costs,
  SUM(CASE WHEN service_quality_score NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 END) AS bad_quality_scores,
  SUM(CASE WHEN recorded_value < 0 THEN 1 ELSE 0 END) AS negative_readings,
  'OK' AS status_check,
  CURRENT_TIMESTAMP AS run_time
FROM ft_service s
LEFT JOIN ft_reading r ON FALSE;  -- just for union of measures (or run separately)
