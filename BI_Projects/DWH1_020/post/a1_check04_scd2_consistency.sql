SET search_path TO dwh_020;

SELECT
  COUNT(*) AS overlapping_rows,
  CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'FAIL' END AS status_check,
  CURRENT_TIMESTAMP AS run_time
FROM (
  SELECT t1.employee_id
  FROM dim_technician_role_scd2 t1
  JOIN dim_technician_role_scd2 t2
    ON t1.employee_id = t2.employee_id
   AND t1.sk_technician_role <> t2.sk_technician_role
   AND daterange(t1.effective_from, t1.effective_to, '[]')
       && daterange(t2.effective_from, t2.effective_to, '[]')
) q;
