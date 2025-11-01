SET search_path TO dwh_020, stg_020;

-- ============================================================
-- ETL Step: Load ft_reading fact table
-- ============================================================

TRUNCATE TABLE ft_reading RESTART IDENTITY CASCADE;

WITH readings AS (
  SELECT
      re.id AS reading_id,
      re.sensordevid AS device_id,
      re.paramid,
      re.readingmodeid,
      re.readat AS reading_date,
      re.recordedvalue AS recorded_value,
      re.datavolumekb / 1024.0 AS data_volume_mb,  -- convert KB to MB
      re.dataquality AS data_quality_score,
      CASE 
          WHEN pa.threshold IS NOT NULL AND re.recordedvalue > pa.threshold 
          THEN TRUE 
          ELSE FALSE 
      END AS exceedance_flag
  FROM tb_readingevent re
  LEFT JOIN tb_paramalert pa 
         ON pa.paramid = re.paramid
)

INSERT INTO ft_reading (
    day_id,
    sk_device_geo,
    sk_parameter,
    sk_readingmode,
    recorded_value,
    data_volume_mb,
    data_quality_score,
    exceedance_flag,
    etl_load_timestamp
)
SELECT
  TO_CHAR(r.reading_date, 'YYYYMMDD')::INT AS day_id,
  dd.sk_device_geo,
  dp.sk_parameter,
  drm.sk_readingmode,
  r.recorded_value,
  r.data_volume_mb,
  r.data_quality_score,
  r.exceedance_flag,
  CURRENT_TIMESTAMP
FROM readings r
JOIN dim_device_geo dd 
     ON dd.device_id = r.device_id
JOIN dim_parameter dp 
     ON dp.tb_param_id = r.paramid
JOIN dim_readingmode drm 
     ON drm.mode_code = r.readingmodeid::text   
ORDER BY day_id;
