-- please remember to give a meaningful name to both Table X (instead of tb_x) and TableY (instead of tb_y)

-- Make the A1's stg_020 schema the default for this session
SET search_path TO stg_020;

-- -------------------------------
-- 2) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_campaign_device;
DROP TABLE IF EXISTS tb_campaign;

-- give a meaningful name and create Table X
CREATE TABLE tb_campaign (
    id INT PRIMARY KEY,
    campaign_name VARCHAR(255) NOT NULL,
    objective TEXT,
    sponsor VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- give a meaningful name and create Table Y
CREATE TABLE tb_campaign_device (
    campaign_id INT NOT NULL,
    device_id INT NOT NULL,
    assigned_from DATE NOT NULL,
    assigned_to DATE,
    priority INT,
    etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_campaign_device_campaign FOREIGN KEY (campaign_id) REFERENCES tb_campaign(id),
    CONSTRAINT fk_campaign_device_device FOREIGN KEY (device_id) REFERENCES tb_sensordevice(id)
);

