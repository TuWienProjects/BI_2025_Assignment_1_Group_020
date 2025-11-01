SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_servicetype
-- =======================================

TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

INSERT INTO dim_servicetype (
    tb_servicetype_id,
    type_name,
    service_group,
    category,
    min_required_level,
    etl_load_timestamp
)
SELECT DISTINCT
    st.id,
    st.typename,
    st.servicegroup,
    st.category,
    st.minlevel,
    CURRENT_TIMESTAMP
FROM tb_servicetype st
ORDER BY st.id;
