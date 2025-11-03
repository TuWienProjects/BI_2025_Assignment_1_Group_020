SET search_path TO dwh_020, stg_020;

TRUNCATE TABLE ft_reading RESTART IDENTITY CASCADE;

WITH src AS (
    SELECT
        re.id              AS reading_id,
        re.sensordevid     AS device_id,
        re.paramid         AS param_id,
        re.readingmodeid   AS readingmode_id,
        re.readat          AS read_at,
        re.recordedvalue   AS recorded_value,
        (re.datavolumekb / 1024.0) AS data_volume_mb,
        re.dataquality     AS data_quality_score
    FROM tb_readingevent re
),

-- optional campaign match: device + date in range
campaign_match AS (
    SELECT
        cd.device_id,
        cd.campaign_id,
        cd.assigned_from,
        COALESCE(cd.assigned_to, DATE '9999-12-31') AS assigned_to,
        cd.priority,
        ROW_NUMBER() OVER (
            PARTITION BY cd.device_id, cd.assigned_from, COALESCE(cd.assigned_to, DATE '9999-12-31')
            ORDER BY cd.priority DESC, cd.campaign_id
        ) AS rn
    FROM tb_campaign_device cd
),

enriched AS (
    SELECT
        s.*,
        dgl.sk_device_geo,
        dp.sk_parameter,
        drm.sk_readingmode,
        dc.sk_campaign,
        -- build day_id from date
        TO_CHAR(s.read_at, 'YYYYMMDD')::INT AS day_id,
        -- exceedance flag (simple)
        CASE
            WHEN pa.threshold IS NOT NULL AND s.recorded_value > pa.threshold THEN TRUE
            ELSE FALSE
        END AS exceedance_flag
    FROM src s
    JOIN dim_device_geo dgl
      ON dgl.device_id = s.device_id
    JOIN dim_parameter dp
      ON dp.tb_param_id = s.param_id
    JOIN dim_readingmode drm
      ON drm.mode_code = s.readingmode_id::text
    LEFT JOIN campaign_match cm
      ON cm.device_id = s.device_id
     AND s.read_at BETWEEN cm.assigned_from AND cm.assigned_to
     AND cm.rn = 1
    LEFT JOIN dim_campaign dc
      ON dc.campaign_id = cm.campaign_id
    LEFT JOIN tb_paramalert pa
      ON pa.paramid = s.param_id
)

INSERT INTO ft_reading (
    day_id,
    sk_device_geo,
    sk_parameter,
    sk_readingmode,
    sk_campaign,
    recorded_value,
    data_volume_mb,
    data_quality_score,
    exceedance_flag,
    etl_load_timestamp
)
SELECT
    e.day_id,
    e.sk_device_geo,
    e.sk_parameter,
    e.sk_readingmode,
    e.sk_campaign,
    e.recorded_value,
    e.data_volume_mb,
    e.data_quality_score,
    e.exceedance_flag,
    CURRENT_TIMESTAMP
FROM enriched e
ORDER BY e.day_id, e.device_id, e.reading_id;
