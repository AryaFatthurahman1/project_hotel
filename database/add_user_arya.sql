-- Add user with email 'arya' for easy login
-- Password is '123' (will be hashed)
USE hotel_arya;

-- Check if user already exists
INSERT IGNORE INTO users (nim, nama_lengkap, email, password, phone, role) 
VALUES ('2023230006', 'Muhammad Arya Fatthurahman', 'arya', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '08123456789', 'admin');

-- Also add a simple password hash for '123'
UPDATE users SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' 
WHERE email = 'arya';
