SET search_path TO dwh_020, stg_020;

-- =======================================
-- Load dim_device_geo (conformed)
-- =======================================

TRUNCATE TABLE dim_device_geo RESTART IDENTITY CASCADE;

INSERT INTO dim_device_geo (
    device_id,
    device_name,
    city_name,
    country_name,
    sensortype,
    manufacturer,
    install_date,
    altitude_m,
    etl_load_timestamp
)
SELECT
    d.id                              AS device_id,
    d.locationname                    AS device_name,
    c.cityname                        AS city_name,
    co.countryname                    AS country_name,
    st.typename                       AS sensortype,
    st.manufacturer                   AS manufacturer,
    d.installedat                     AS install_date,
    d.altitude                        AS altitude_m,
    CURRENT_TIMESTAMP
FROM tb_sensordevice d
JOIN tb_city     c  ON d.cityid      = c.id
JOIN tb_country  co ON c.countryid   = co.id
JOIN tb_sensortype st ON d.sensortypeid = st.id
ORDER BY d.id;
