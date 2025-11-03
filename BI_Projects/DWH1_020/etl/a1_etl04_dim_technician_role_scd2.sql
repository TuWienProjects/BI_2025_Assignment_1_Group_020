SET search_path TO dwh_020, stg_020;

TRUNCATE TABLE dim_technician_role_scd2 RESTART IDENTITY CASCADE;

-- Staging has “current” roles encoded as validfrom/validto
-- We turn them into SCD2 rows, 1:1 with staging

INSERT INTO dim_technician_role_scd2 (
    employee_id,
    badge_number,
    role_name,
    role_level,
    effective_from,
    effective_to,
    is_current,
    etl_load_timestamp
)
SELECT
    e.id                  AS employee_id,
    e.badgenumber         AS badge_number,
    r.rolename            AS role_name,
    r.rolelevel           AS role_level,
    e.validfrom           AS effective_from,
    COALESCE(e.validto, DATE '9999-12-31') AS effective_to,
    (e.validto IS NULL OR e.validto >= CURRENT_DATE) AS is_current,
    CURRENT_TIMESTAMP
FROM tb_employee e
JOIN tb_role r
  ON e.roleid = r.id
ORDER BY e.id, e.validfrom;
