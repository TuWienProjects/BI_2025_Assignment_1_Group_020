SET search_path TO dwh_020, stg_020;

-- ============================================================
-- ETL Step: Load ft_service fact table
-- ============================================================

TRUNCATE TABLE ft_service RESTART IDENTITY CASCADE;

WITH svc AS (
  SELECT
      s.id AS service_id,
      s.sensordevid AS device_id,
      s.servicedat AS service_date,
      s.servicetypeid,
      s.employeeid,
      s.servicecost AS service_cost_eur,
      s.durationminutes AS duration_minutes,
      s.servicequality AS service_quality_score
  FROM tb_serviceevent s
),

role_lookup AS (
  SELECT
      dtr.sk_technician_role,
      dtr.employee_id,
      dtr.role_level,
      td.date
  FROM dim_technician_role_scd2 dtr
  JOIN dim_timeday td 
    ON td.date BETWEEN dtr.effective_from AND dtr.effective_to
)

INSERT INTO ft_service (
    day_id,
    sk_device_geo,
    sk_servicetype,
    sk_technician_role,
    service_cost_eur,
    duration_minutes,
    service_quality_score,
    underqualified_flag,
    etl_load_timestamp
)
SELECT
  TO_CHAR(s.service_date, 'YYYYMMDD')::INT AS day_id,
  dd.sk_device_geo,
  dst.sk_servicetype,
  rl.sk_technician_role,
  s.service_cost_eur,
  s.duration_minutes,
  s.service_quality_score,
  CASE 
      WHEN dtr.role_level < dst.min_required_level THEN TRUE 
      ELSE FALSE 
  END AS underqualified_flag,
  CURRENT_TIMESTAMP
FROM svc s
JOIN dim_device_geo dd 
     ON dd.device_id = s.device_id
JOIN dim_servicetype dst 
     ON dst.tb_servicetype_id = s.servicetypeid
JOIN role_lookup rl 
     ON rl.employee_id = s.employeeid 
    AND rl.date = s.service_date
JOIN dim_technician_role_scd2 dtr 
     ON dtr.sk_technician_role = rl.sk_technician_role
ORDER BY day_id;
