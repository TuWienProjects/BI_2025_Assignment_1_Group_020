SET search_path TO dwh_020, stg_020;

TRUNCATE TABLE dim_parameter RESTART IDENTITY CASCADE;

INSERT INTO dim_parameter (
    tb_param_id,
    paramname,
    parameter_group,
    parameter_family,
    unit,
    etl_load_timestamp
)
SELECT
    p.id           AS tb_param_id,
    p.paramname,
    p.category     AS parameter_group,
    p.purpose      AS parameter_family,
    p.unit,
    CURRENT_TIMESTAMP
FROM tb_param p
ORDER BY p.id;
