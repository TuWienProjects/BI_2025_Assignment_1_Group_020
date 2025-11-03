SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_campaign (synthetic dimension)
-- =======================================

TRUNCATE TABLE dim_campaign RESTART IDENTITY CASCADE;

INSERT INTO dim_campaign (
    campaign_id,
    campaign_name,
    objective,
    sponsor,
    start_date,
    end_date,
    etl_load_timestamp
)
SELECT
    id,
    campaign_name,
    objective,
    sponsor,
    start_date,
    end_date,
    CURRENT_TIMESTAMP
FROM tb_campaign
ORDER BY id;
