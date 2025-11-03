SET search_path TO dwh_020, stg_020;

TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

INSERT INTO dim_servicetype (
    tb_servicetype_id,
    type_name,
    service_group,
    category,
    min_required_level,
    etl_load_timestamp
)
SELECT
    s.id              AS tb_servicetype_id,
    s.typename        AS type_name,
    s.servicegroup    AS service_group,
    s.category        AS category,
    s.minlevel        AS min_required_level,
    CURRENT_TIMESTAMP
FROM tb_servicetype s
ORDER BY s.id;
