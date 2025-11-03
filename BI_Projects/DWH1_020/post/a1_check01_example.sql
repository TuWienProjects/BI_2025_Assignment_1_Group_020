-- Make A1 dwh_020 schema the default for this session
SET search_path TO dwh_020, stg_020;

-- =======================================
-- Check [what are you checking]
-- =======================================
WITH dwh_st AS 
(
  SELECT '020' as group_num
  	, COUNT(sk_servicetype) as dwh_count
  FROM dim_servicetype
),
stg_st AS 
(
  SELECT '020' as group_num
  	, COUNT(id) as stg_count
  FROM tb_servicetype
)
SELECT
  d.dwh_count
  , s.stg_count
  , CASE WHEN d.dwh_count = s.stg_count THEN 'OK' ELSE 'fail' END AS status_check
  , CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM dwh_st d
INNER JOIN stg_st s on d.group_num = s.group_num


