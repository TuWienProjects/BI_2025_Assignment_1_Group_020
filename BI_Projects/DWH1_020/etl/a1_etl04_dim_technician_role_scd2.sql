SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_technician_role_scd2 (SCD Type 2)
-- =======================================

TRUNCATE TABLE dim_technician_role_scd2 RESTART IDENTITY CASCADE;

WITH role_history AS (
  SELECT
      e.id AS employee_id,
      e.badgenumber,
      r.rolename,
      r.rolelevel,
      e.validfrom AS effective_from,
      COALESCE(e.validto, DATE '9999-12-31') AS effective_to,
      (e.validto IS NULL) AS is_current
  FROM tb_employee e
  JOIN tb_role r ON r.id = e.roleid
)
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
    employee_id,
    badgenumber,
    rolename,
    rolelevel,
    effective_from,
    effective_to,
    is_current,
    CURRENT_TIMESTAMP
FROM role_history
ORDER BY employee_id, effective_from;
