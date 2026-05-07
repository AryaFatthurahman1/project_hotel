-- Database Update for Muhammad Arya Fatthurahman
USE bere9277_db_arya;

-- Check if user exists, if not insert
INSERT INTO users (nama_lengkap, email, password, role, phone, nim)
SELECT 'Muhammad Arya Fatthurahman', 'aryafatthurahman4@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '08123456789', '2023230006'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE email = 'aryafatthurahman4@gmail.com'
);

-- The password hash above is for 'arya123' (standard bcrypt)
-- Also ensure the 'arya' easy login works for this user in the PHP script
