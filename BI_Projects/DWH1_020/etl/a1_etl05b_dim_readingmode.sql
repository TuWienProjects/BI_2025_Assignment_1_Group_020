SET search_path TO dwh_020, stg_020;

TRUNCATE TABLE dim_readingmode RESTART IDENTITY CASCADE;

INSERT INTO dim_readingmode (
    mode_code,
    mode_name,
    valid_from,
    valid_to,
    etl_load_timestamp
)
SELECT
    rm.id::text       AS mode_code,
    rm.modename       AS mode_name,
    rm.validfrom      AS valid_from,
    rm.validto        AS valid_to,
    CURRENT_TIMESTAMP
FROM tb_readingmode rm
ORDER BY rm.id;
