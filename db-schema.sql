-- DB-SCHEMA.SQL
-- File này chứa tất cả cấu trúc database của dự án
-- Cập nhật lần cuối: 2024-05-15

-- ========================================================
-- DATABASE: user_management
-- MỤC ĐÍCH: Quản lý thông tin người dùng và phân quyền
-- NGÀY TẠO: 2024-05-15
-- NGƯỜI TẠO: dev_team
-- LỊCH SỬ CẬP NHẬT:
-- 2024-05-15 - dev_team - Tạo cấu trúc ban đầu
-- ========================================================

CREATE DATABASE IF NOT EXISTS user_management;
USE user_management;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

ALTER TABLE user_roles
ADD CONSTRAINT fk_user_roles_user
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_user_roles_role
FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;

-- Dữ liệu ban đầu
INSERT INTO roles (name, description) VALUES
('admin', 'Quản trị viên với toàn quyền'),
('user', 'Người dùng thông thường');

-- ========================================================
-- DATABASE: app_config
-- MỤC ĐÍCH: Lưu trữ cấu hình ứng dụng
-- NGÀY TẠO: 2024-05-15
-- NGƯỜI TẠO: dev_team
-- LỊCH SỬ CẬP NHẬT:
-- 2024-05-15 - dev_team - Tạo cấu trúc ban đầu
-- ========================================================

CREATE DATABASE IF NOT EXISTS app_config;
USE app_config;

CREATE TABLE IF NOT EXISTS settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    data_type ENUM('string', 'integer', 'float', 'boolean', 'json') NOT NULL DEFAULT 'string',
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS feature_flags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    feature_name VARCHAR(100) NOT NULL UNIQUE,
    is_enabled BOOLEAN DEFAULT FALSE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Dữ liệu ban đầu
INSERT INTO settings (setting_key, setting_value, data_type, description, is_system) VALUES
('app_name', 'Base AI Project', 'string', 'Tên ứng dụng', TRUE),
('debug_mode', 'false', 'boolean', 'Chế độ debug', TRUE),
('api_rate_limit', '100', 'integer', 'Giới hạn số lượng API call mỗi phút', TRUE);

INSERT INTO feature_flags (feature_name, is_enabled, description) VALUES
('dark_mode', TRUE, 'Kích hoạt chế độ tối'),
('beta_features', FALSE, 'Kích hoạt tính năng đang phát triển');

-- ========================================================
-- DATABASE: logs
-- MỤC ĐÍCH: Lưu trữ logs hệ thống
-- NGÀY TẠO: 2024-05-15
-- NGƯỜI TẠO: dev_team
-- LỊCH SỬ CẬP NHẬT:
-- 2024-05-15 - dev_team - Tạo cấu trúc ban đầu
-- ========================================================

CREATE DATABASE IF NOT EXISTS logs;
USE logs;

CREATE TABLE IF NOT EXISTS system_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_level ENUM('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL') NOT NULL,
    component VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_activity (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_activity_user_id (user_id),
    INDEX idx_user_activity_action (action),
    INDEX idx_user_activity_created_at (created_at)
);

-- Tạo các view cho các truy vấn thường dùng
CREATE VIEW recent_errors AS
SELECT * FROM system_logs
WHERE log_level IN ('ERROR', 'CRITICAL')
ORDER BY created_at DESC
LIMIT 100;

-- ========================================================
-- END OF SCHEMA DEFINITIONS
-- ======================================================== 