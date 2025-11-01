-- =============================================
-- Assignment 1: Create Data Warehouse schema for Group 020
-- =============================================

-- Make DWH schema the default for this session
SET search_path TO dwh_020;

-- -------------------------------
-- 1) DROP TABLES in dependency order
-- -------------------------------
DROP TABLE IF EXISTS ft_service CASCADE;
DROP TABLE IF EXISTS ft_reading CASCADE;
DROP TABLE IF EXISTS dim_campaign CASCADE;
DROP TABLE IF EXISTS dim_technician_role_scd2 CASCADE;
DROP TABLE IF EXISTS dim_servicetype CASCADE;
DROP TABLE IF EXISTS dim_parameter CASCADE;
DROP TABLE IF EXISTS dim_device_geo CASCADE;
DROP TABLE IF EXISTS dim_readingmode CASCADE;
DROP TABLE IF EXISTS dim_timeday CASCADE;

-- -------------------------------
-- 2) CREATE DIMENSION TABLES
-- -------------------------------

-- Time dimension (shared)
CREATE TABLE dim_timeday (
    id INT PRIMARY KEY,  -- YYYYMMDD format
    date DATE NOT NULL,
    year INT,
    quarter INT,
    month INT,
    week INT,
    day_of_month INT,
    day_of_week INT,
    is_weekend BOOLEAN,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Device + Geography dimension (conformed)
CREATE TABLE dim_device_geo (
    sk_device_geo BIGSERIAL PRIMARY KEY,
    device_id INT NOT NULL,               -- business key from OLTP
    device_name VARCHAR(255),
    city_name VARCHAR(255),
    country_name VARCHAR(255),
    sensortype VARCHAR(255),
    manufacturer VARCHAR(255),
    install_date DATE,
    altitude_m INT,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_dim_device_geo_bk UNIQUE (device_id)
);

-- Parameter dimension
CREATE TABLE dim_parameter (
    sk_parameter BIGSERIAL PRIMARY KEY,
    tb_param_id INT NOT NULL,             -- ID from OLTP
    paramname VARCHAR(200) NOT NULL,
    parameter_group VARCHAR(200),
    parameter_family VARCHAR(200),
    unit VARCHAR(50),
    etl_load_timestamp TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_dim_parameter_bk UNIQUE (tb_param_id)
);

-- Reading mode dimension (Type 1 SCD)
CREATE TABLE dim_readingmode (
    sk_readingmode BIGSERIAL PRIMARY KEY,
    mode_code VARCHAR(100) NOT NULL,
    mode_name VARCHAR(200),
    valid_from DATE,
    valid_to DATE,
    etl_load_timestamp TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_dim_readingmode_bk UNIQUE (mode_code)
);

-- Service type dimension
CREATE TABLE dim_servicetype (
    sk_servicetype BIGSERIAL PRIMARY KEY,
    tb_servicetype_id INT NOT NULL,
    type_name VARCHAR(200) NOT NULL,
    service_group VARCHAR(200),
    category VARCHAR(200),
    min_required_level INT,
    etl_load_timestamp TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_dim_servicetype_bk UNIQUE (tb_servicetype_id)
);

-- Technician role (SCD Type 2)
CREATE TABLE dim_technician_role_scd2 (
    sk_technician_role BIGSERIAL PRIMARY KEY,
    employee_id INT NOT NULL,             -- BK from OLTP
    badge_number VARCHAR(255) NOT NULL,
    role_name VARCHAR(255) NOT NULL,
    role_level INT NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ux_techrole_timerange UNIQUE (badge_number, effective_from, effective_to)
);

-- Synthetic dimension (from Table X)
CREATE TABLE dim_campaign (
    sk_campaign BIGSERIAL PRIMARY KEY,
    campaign_id INT NOT NULL,
    campaign_name VARCHAR(255) NOT NULL,
    objective TEXT,
    sponsor VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_dim_campaign_bk UNIQUE (campaign_id)
);

-- -------------------------------
-- 3) CREATE FACT TABLES
-- -------------------------------

-- FACT 1: Environmental readings
CREATE TABLE ft_reading (
    sk_reading BIGSERIAL PRIMARY KEY,
    day_id INT NOT NULL REFERENCES dim_timeday(id),
    sk_device_geo BIGINT NOT NULL REFERENCES dim_device_geo(sk_device_geo),
    sk_parameter BIGINT NOT NULL REFERENCES dim_parameter(sk_parameter),
    sk_readingmode BIGINT NOT NULL REFERENCES dim_readingmode(sk_readingmode),
    sk_campaign BIGINT REFERENCES dim_campaign(sk_campaign),

    recorded_value NUMERIC(12,4),
    data_volume_mb NUMERIC(12,2),
    data_quality_score NUMERIC(12,2),
    exceedance_flag BOOLEAN,

    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ix_ft_reading_day ON ft_reading(day_id);
CREATE INDEX ix_ft_reading_device ON ft_reading(sk_device_geo);
CREATE INDEX ix_ft_reading_param ON ft_reading(sk_parameter);

-- FACT 2: Service operations
CREATE TABLE ft_service (
    sk_service BIGSERIAL PRIMARY KEY,
    day_id INT NOT NULL REFERENCES dim_timeday(id),
    sk_device_geo BIGINT NOT NULL REFERENCES dim_device_geo(sk_device_geo),
    sk_servicetype BIGINT NOT NULL REFERENCES dim_servicetype(sk_servicetype),
    sk_technician_role BIGINT NOT NULL REFERENCES dim_technician_role_scd2(sk_technician_role),
    sk_campaign BIGINT REFERENCES dim_campaign(sk_campaign),

    service_cost_eur NUMERIC(12,2),
    duration_minutes INT,
    service_quality_score NUMERIC(12,2),
    underqualified_flag BOOLEAN,

    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ix_ft_service_day ON ft_service(day_id);
CREATE INDEX ix_ft_service_device ON ft_service(sk_device_geo);
CREATE INDEX ix_ft_service_type ON ft_service(sk_servicetype);
CREATE INDEX ix_ft_service_tech ON ft_service(sk_technician_role);