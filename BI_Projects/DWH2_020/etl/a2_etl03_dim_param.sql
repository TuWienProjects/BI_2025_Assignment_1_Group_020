-- Assignment 2 ETL: dim_param
-- HINT: Pull from stg_xxx.tb_param:
--   param_name, param_code (optional), category, purpose, unit
-- EXAMPLE SHAPE:
-- TRUNCATE TABLE dwh2_xxx.dim_param;
-- INSERT INTO dwh2_xxx.dim_param (...)
-- SELECT p.paramname, NULL, p.category, p.purpose, p.unit FROM stg_xxx.tb_param p;

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_020, stg2_020;

-- =======================================
-- Load dim_param
-- =======================================

-- Step 1: Truncate target table - dim_param
TRUNCATE TABLE dim_param CASCADE;


-- Step 2: Insert data into the dim_param
-- Param (Purpose → Category → Param)
-- Insert into dim_param with explicit param_key values
INSERT INTO dim_param (
    param_key,
    param_name,
    param_code,
    category,
    purpose,
    unit
)
OVERRIDING SYSTEM VALUE     -- This allows inserting explicit param_key values
SELECT
    p.id,                   -- TRUE param ID from staging (1001–1030)
    p.paramname,
    NULL,                   -- param_code is not used
    p.category,
    p.purpose,
    p.unit
FROM stg2_020.tb_param p
ORDER BY p.id;


