-- Make the A1's stg_020 schema the default for this session
SET search_path TO stg_020;

-- -------------------------------
-- 2) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_serviceevent;
DROP TABLE IF EXISTS tb_readingevent;
DROP TABLE IF EXISTS tb_weather;
DROP TABLE IF EXISTS tb_sensordevice;
DROP TABLE IF EXISTS tb_paramsensortype;
DROP TABLE IF EXISTS tb_paramalert;
DROP TABLE IF EXISTS tb_employee;
DROP TABLE IF EXISTS tb_param;
DROP TABLE IF EXISTS tb_alert;
DROP TABLE IF EXISTS tb_readingmode;
DROP TABLE IF EXISTS tb_sensortype;
DROP TABLE IF EXISTS tb_servicetype;
DROP TABLE IF EXISTS tb_role;
DROP TABLE IF EXISTS tb_city;
DROP TABLE IF EXISTS tb_country;

-- -------------------------------
-- 3) CREATE TABLE statements (dependency-safe order)
-- -------------------------------

-- 1) Country
CREATE TABLE tb_country (
    id INT NOT NULL PRIMARY KEY,
    countryname VARCHAR(255) NOT NULL,
    population INT NOT NULL,
    CONSTRAINT uc_country_countryname UNIQUE (countryname)
);

-- 2) City (depends on country)
CREATE TABLE tb_city (
    id INT NOT NULL PRIMARY KEY,
    countryid INT NOT NULL,
    cityname VARCHAR(255) NOT NULL,
    population INT NOT NULL,
    latitude DECIMAL(10,4) NOT NULL,
    longitude DECIMAL(10,4) NOT NULL,
    CONSTRAINT uc_city_countryid_cityname UNIQUE (countryid, cityname),
    CONSTRAINT fk_city_countryid FOREIGN KEY (countryid) REFERENCES tb_country(id)
);

-- 3) Role
CREATE TABLE tb_role (
    id INT NOT NULL PRIMARY KEY,
    rolelevel INT NOT NULL,
    category VARCHAR(255) NOT NULL,
    rolename VARCHAR(255) NOT NULL,
    CHECK (rolelevel IN (1, 2, 3, 4)),
    CHECK (category IN ('Hardware', 'Software', 'Diagnostics', 'Calibration')),
    CONSTRAINT uc_role_rolename UNIQUE (rolename)
);

-- 4) Service type
CREATE TABLE tb_servicetype (
    id INT NOT NULL PRIMARY KEY,
    typename VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    minlevel INT NOT NULL,
    servicegroup VARCHAR(255) NOT NULL,
    details VARCHAR(255) NOT NULL,
    CHECK (minlevel IN (1, 2, 3, 4)),
    CHECK (category IN ('Hardware', 'Software', 'Diagnostics', 'Calibration'))
);

-- 5) Employee (depends on role)
CREATE TABLE tb_employee (
    id INT NOT NULL PRIMARY KEY,
    roleid INT NOT NULL,
    badgenumber VARCHAR(255) NOT NULL,
    validfrom DATE NOT NULL,
    validto DATE NULL,
    CONSTRAINT fk_employee_roleid FOREIGN KEY (roleid) REFERENCES tb_role(id)
);

-- 6) Parameter
CREATE TABLE tb_param (
    id INT NOT NULL PRIMARY KEY,
    paramname VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    purpose VARCHAR(50) NOT NULL,
    unit VARCHAR(255) NOT NULL,
    CHECK (category IN ('Particulate matter', 'Gas', 'Heavy Metal', 'Volatile Organic Compound', 'Biological')),
    CHECK (purpose IN ('Health Risk', 'Comfort', 'Environmental Monitoring', 'Scientific Study', 'Regulatory Compliance')),
    CONSTRAINT uc_param_paramname UNIQUE (paramname)
);

-- 7) Alert
CREATE TABLE tb_alert (
    id INT NOT NULL PRIMARY KEY,
    alertname VARCHAR(255) NOT NULL,
    colour VARCHAR(255) NOT NULL,
    details VARCHAR(255) NOT NULL,
    CONSTRAINT uc_alert_alertname UNIQUE (alertname)
);

-- 8) ParamAlert (depends on param + alert)
CREATE TABLE tb_paramalert (
    id INT NOT NULL PRIMARY KEY,
    paramid INT NOT NULL,
    alertid INT NOT NULL,
    threshold DECIMAL(10,4) NOT NULL,
    CONSTRAINT fk_paramalert_paramid FOREIGN KEY (paramid) REFERENCES tb_param(id),
    CONSTRAINT fk_paramalert_alertid FOREIGN KEY (alertid) REFERENCES tb_alert(id),
    CONSTRAINT uc_param_alert UNIQUE (paramid, alertid)
);

-- 9) Sensor type
CREATE TABLE tb_sensortype (
    id INT NOT NULL PRIMARY KEY,
    typename VARCHAR(255) NOT NULL,
    manufacturer VARCHAR(255) NOT NULL,
    technology VARCHAR(255) NOT NULL,
    CHECK (manufacturer IN ('Sensirion', 'Bosch', 'Honeywell', 'Other')),
    CHECK (technology IN ('Optical', 'Electrochemical', 'Laser'))
);

-- 10) ParamSensorType (depends on sensortype + param)
CREATE TABLE tb_paramsensortype (
    id INT NOT NULL PRIMARY KEY,
    sensortypeid INT NOT NULL,
    paramid INT NOT NULL,
    accuracy VARCHAR(255) NOT NULL,
    CHECK (accuracy IN ('High', 'Medium', 'Low')),
    CONSTRAINT fk_paramsensortype_sensortypeid FOREIGN KEY (sensortypeid) REFERENCES tb_sensortype(id),
    CONSTRAINT fk_paramsensortype_paramid FOREIGN KEY (paramid) REFERENCES tb_param(id),
    CONSTRAINT uc_param_sensortype UNIQUE (paramid, sensortypeid)
);

-- 11) Sensor device (depends on sensortype + city)
CREATE TABLE tb_sensordevice (
    id INT NOT NULL PRIMARY KEY,
    sensortypeid INT NOT NULL,
    cityid INT NOT NULL,
    locationname VARCHAR(255) NOT NULL,
    locationtype VARCHAR(255) NOT NULL,
    altitude INT NOT NULL,
    installedat DATE NOT NULL,
    CHECK (locationtype IN ('Urban', 'Suburban', 'Industrial', 'Other')),
    CONSTRAINT fk_sensordevice_sensortypeid FOREIGN KEY (sensortypeid) REFERENCES tb_sensortype(id),
    CONSTRAINT fk_sensordevice_cityid FOREIGN KEY (cityid) REFERENCES tb_city(id)
);

-- 12) Reading mode
CREATE TABLE tb_readingmode (
    id INT NOT NULL PRIMARY KEY,
    modename VARCHAR(255) NOT NULL,
    latency INT NOT NULL,
    validfrom DATE NOT NULL,
    validto DATE NULL,
    details VARCHAR(255) NOT NULL,
    CHECK (modename IN ('Rapid', 'Low Power', 'Standard', 'High Precision')),
    CHECK (latency IN (1, 2, 5, 10))
);

-- 13) Reading event (depends on sensordevice + param + readingmode)
CREATE TABLE tb_readingevent (
    id INT NOT NULL PRIMARY KEY,
    sensordevid INT NOT NULL,
    paramid INT NOT NULL,
    readingmodeid INT NOT NULL,
    readat DATE NOT NULL,
    recordedvalue DECIMAL(10,4) NOT NULL,
    datavolumekb INT NOT NULL,
    dataquality INT NOT NULL,
    CHECK (dataquality BETWEEN 1 AND 5),
    CONSTRAINT fk_readingevent_sensordevid FOREIGN KEY (sensordevid) REFERENCES tb_sensordevice(id),
    CONSTRAINT fk_readingevent_paramid FOREIGN KEY (paramid) REFERENCES tb_param(id),
    CONSTRAINT fk_readingevent_readingmodeid FOREIGN KEY (readingmodeid) REFERENCES tb_readingmode(id)
);

-- 14) Service event (depends on servicetype + employee + sensordevice)
CREATE TABLE tb_serviceevent (
    id INT NOT NULL PRIMARY KEY,
    servicetypeid INT NOT NULL,
    employeeid INT NOT NULL,
    sensordevid INT NOT NULL,
    servicedat DATE NOT NULL,
    servicecost INT NOT NULL,
    durationminutes INT NOT NULL,
    servicequality INT NOT NULL,
    CHECK (servicecost >= 0),
    CHECK (durationminutes >= 0),
    CHECK (servicequality BETWEEN 1 AND 5),
    CONSTRAINT fk_serviceevent_servicetypeid FOREIGN KEY (servicetypeid) REFERENCES tb_servicetype(id),
    CONSTRAINT fk_serviceevent_employeeid FOREIGN KEY (employeeid) REFERENCES tb_employee(id),
    CONSTRAINT fk_serviceevent_sensordevid FOREIGN KEY (sensordevid) REFERENCES tb_sensordevice(id)
);

-- 15) Weather (depends on city)
CREATE TABLE tb_weather (
    id INT NOT NULL PRIMARY KEY,
    cityid INT NOT NULL,
    observedat DATE NOT NULL,
    tempdaymin DECIMAL(6,1) NULL,
    tempdaymax DECIMAL(6,1) NULL,
    tempdayavg DECIMAL(6,1) NULL,
    precipmm DECIMAL(6,1) NULL,
    pressure DECIMAL(6,1) NULL,
    windspeed DECIMAL(6,1) NULL,
    windgusts DECIMAL(6,1) NULL,
    CONSTRAINT fk_weather_cityid FOREIGN KEY (cityid) REFERENCES tb_city(id),
    CONSTRAINT uc_city_observedat UNIQUE (cityid, observedat)
);
