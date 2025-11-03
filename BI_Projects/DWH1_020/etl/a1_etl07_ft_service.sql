SET search_path TO dwh_020, stg_020;

TRUNCATE TABLE ft_service RESTART IDENTITY CASCADE;

WITH svc AS (
    SELECT
        s.id             AS service_id,
        s.sensordevid    AS device_id,
        s.servicedat     AS service_date,
        s.servicetypeid  AS servicetype_id,
        s.employeeid     AS employee_id,
        s.servicecost    AS service_cost_eur,
        s.durationminutes AS duration_minutes,
        s.servicequality  AS service_quality_score
    FROM tb_serviceevent s
),

-- match technician role SCD2 by employee + service_date
role_match AS (
    SELECT
        dtr.sk_technician_role,
        dtr.employee_id,
        dtr.role_level,
        dtr.effective_from,
        dtr.effective_to
    FROM dim_technician_role_scd2 dtr
),

-- optional campaign match
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
)

INSERT INTO ft_service (
    day_id,
    sk_device_geo,
    sk_servicetype,
    sk_technician_role,
    sk_campaign,
    service_cost_eur,
    duration_minutes,
    service_quality_score,
    underqualified_flag,
    etl_load_timestamp
)
SELECT
    TO_CHAR(s.service_date, 'YYYYMMDD')::INT AS day_id,
    ddg.sk_device_geo,
    dst.sk_servicetype,
    dtr.sk_technician_role,
    dc.sk_campaign,
    s.service_cost_eur,
    s.duration_minutes,
    s.service_quality_score,
    CASE
        WHEN dtr.role_level IS NOT NULL
         AND dst.min_required_level IS NOT NULL
         AND dtr.role_level < dst.min_required_level
        THEN TRUE
        ELSE FALSE
    END AS underqualified_flag,
    CURRENT_TIMESTAMP
FROM svc s
JOIN dim_device_geo ddg
  ON ddg.device_id = s.device_id
JOIN dim_servicetype dst
  ON dst.tb_servicetype_id = s.servicetype_id
JOIN role_match dtr
  ON dtr.employee_id = s.employee_id
 AND s.service_date BETWEEN dtr.effective_from AND dtr.effective_to
LEFT JOIN campaign_match cm
  ON cm.device_id = s.device_id
 AND s.service_date BETWEEN cm.assigned_from AND cm.assigned_to
 AND cm.rn = 1
LEFT JOIN dim_campaign dc
  ON dc.campaign_id = cm.campaign_id
ORDER BY day_id, s.device_id, s.service_id;
