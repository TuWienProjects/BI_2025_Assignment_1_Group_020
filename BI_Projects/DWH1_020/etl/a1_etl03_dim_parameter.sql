SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_parameter
-- =======================================

TRUNCATE TABLE dim_parameter RESTART IDENTITY CASCADE;

INSERT INTO dim_parameter (
    tb_param_id,
    paramname,
    parameter_group,
    parameter_family,
    unit,
    etl_load_timestamp
)
SELECT DISTINCT
    p.id,
    p.paramname,
    p.category,   -- maps to parameter_group
    p.purpose,    -- maps to parameter_family
    p.unit,
    CURRENT_TIMESTAMP
FROM tb_param p
ORDER BY p.id;
