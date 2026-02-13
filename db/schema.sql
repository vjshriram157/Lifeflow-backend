-- Core schema for Online Blood Bank Management System
CREATE DATABASE IF NOT EXISTS blood_bank_db;
USE blood_bank_db;
CREATE TABLE IF NOT EXISTS users (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    password_hash   VARCHAR(255) NOT NULL,
    blood_group     VARCHAR(5),
    role            ENUM('DONOR', 'ADMIN', 'BANK') DEFAULT 'DONOR',
    status          ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    city            VARCHAR(100),
    latitude        DECIMAL(10,8),
    longitude       DECIMAL(11,8),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS blood_banks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    bank_name       VARCHAR(150) NOT NULL,
    email           VARCHAR(120) UNIQUE,
    phone           VARCHAR(20),
    address_line1   VARCHAR(255),
    city            VARCHAR(100),
    pincode         VARCHAR(10),
    latitude        DECIMAL(10,8) NOT NULL,
    longitude       DECIMAL(11,8) NOT NULL,
    status          ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS blood_stock (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    bank_id         BIGINT NOT NULL,
    blood_group     VARCHAR(5) NOT NULL,
    units_available INT NOT NULL DEFAULT 0,
    safety_stock    INT NOT NULL DEFAULT 5,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_stock_bank FOREIGN KEY (bank_id) REFERENCES blood_banks(id)
);

CREATE TABLE IF NOT EXISTS appointments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    donor_id        BIGINT NOT NULL,
    bank_id         BIGINT NOT NULL,
    appointment_time DATETIME NOT NULL,
    status          ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_apt_donor FOREIGN KEY (donor_id) REFERENCES users(id),
    CONSTRAINT fk_apt_bank FOREIGN KEY (bank_id) REFERENCES blood_banks(id)
);

CREATE TABLE IF NOT EXISTS emergency_alerts (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    bank_id         BIGINT NOT NULL,
    blood_group     VARCHAR(5) NOT NULL,
    radius_km       DECIMAL(5,2) NOT NULL DEFAULT 10.0,
    message         VARCHAR(255),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    triggered_by    BIGINT,
    CONSTRAINT fk_alert_bank FOREIGN KEY (bank_id) REFERENCES blood_banks(id)
);

CREATE TABLE IF NOT EXISTS device_tokens (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    device_token    VARCHAR(255) NOT NULL,
    platform        ENUM('ANDROID', 'IOS') NOT NULL,
    last_latitude   DECIMAL(10,8),
    last_longitude  DECIMAL(11,8),
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_device_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Example locator query using Haversine formula (replace :lat and :lng placeholders)
-- SELECT
--     b.id,
--     b.bank_name,
--     b.address_line1,
--     b.city,
--     b.pincode,
--     b.latitude,
--     b.longitude,
--     ( 6371 * ACOS(
--         COS(RADIANS(:lat)) * COS(RADIANS(b.latitude)) *
--         COS(RADIANS(b.longitude) - RADIANS(:lng)) +
--         SIN(RADIANS(:lat)) * SIN(RADIANS(b.latitude))
--     ) ) AS distance_km
-- FROM blood_banks b
-- WHERE b.status = 'APPROVED'
-- HAVING distance_km < :radiusKm
-- ORDER BY distance_km
-- LIMIT 20;
USE blood_bank_db;

INSERT INTO users (full_name, email, phone, password_hash, role, status, city) 
VALUES ('System Admin', 'admin@bloodbank.com', '9999999999', 
'8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 
'ADMIN', 'APPROVED', 'New York');
INSERT INTO users (full_name, email, phone, password_hash, role, status, city) 
VALUES (
    'System Admin', 
    'admin@bloodbank.com', 
    '000-000-0000', 
    '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 
    'ADMIN', 
    'APPROVED', 
    'Headquarters'
)
ON DUPLICATE KEY UPDATE 
    role='ADMIN', 
    status='APPROVED', 
    password_hash='8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918';
