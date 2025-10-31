-- Make A1 dwh_020, stg_020 schemas the default for this session
SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_timeday
-- =======================================

-- Step 1: Truncate target table, the dim_timeday in this case
TRUNCATE TABLE dim_timeday RESTART IDENTITY CASCADE;

-- Step 2: Insert data into the dim_timeday
INSERT INTO dim_timeday (id)
-- place time dimension creating mechanism here
VALUES 
(1)
, (2)
, (3)
, (4)
, (5)




