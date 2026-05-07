-- =====================================================
-- DATABASE SCHEMA FOR GRAND HOTEL APPLICATION
-- Muhammad Arya Fatthurahman - UAS Mobile Computing
-- =====================================================
-- Upload via cPanel phpMyAdmin
-- URL: https://kilimanjaro.iixcp.rumahweb.net:2083/
-- =====================================================

-- Create database (if not exists)
CREATE DATABASE IF NOT EXISTS `bere9277_hotel` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `bere9277_hotel`;

-- =====================================================
-- TABLE 1: USERS (Tabel Pengguna)
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(20) DEFAULT NULL,
    `profile_image` VARCHAR(255) DEFAULT NULL,
    `role` ENUM('user', 'admin') DEFAULT 'user',
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample users
INSERT INTO `users` (`full_name`, `email`, `password`, `phone`, `role`) VALUES
('Admin Hotel', 'admin@grandhotel.com', 'admin123', '081234567890', 'admin'),
('Muhammad Arya', 'arya@gmail.com', 'arya123', '081234567891', 'user'),
('Test User', 'test@test.com', 'test123', '081234567892', 'user');

-- =====================================================
-- TABLE 2: HOTELS (Tabel Hotel/Kamar)
-- =====================================================
CREATE TABLE IF NOT EXISTS `hotels` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT,
    `address` VARCHAR(255),
    `city` VARCHAR(100),
    `price_per_night` DECIMAL(12, 2) NOT NULL,
    `rating` DECIMAL(2, 1) DEFAULT 0.0,
    `image_url` VARCHAR(500),
    `facilities` TEXT,
    `room_type` ENUM('standard', 'deluxe', 'suite', 'presidential') DEFAULT 'standard',
    `is_available` TINYINT(1) DEFAULT 1,
    `total_rooms` INT DEFAULT 10,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample hotels
INSERT INTO `hotels` (`name`, `description`, `address`, `city`, `price_per_night`, `rating`, `image_url`, `facilities`, `room_type`, `total_rooms`) VALUES
('Grand Deluxe Room', 'Kamar mewah dengan pemandangan kota yang menakjubkan. Dilengkapi dengan AC, TV LED 50 inch, dan kamar mandi pribadi.', 'Jl. Sudirman No. 1', 'Jakarta', 850000.00, 4.8, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800', 'WiFi, AC, TV, Mini Bar, Room Service', 'deluxe', 15),
('Presidential Suite', 'Suite premium dengan ruang tamu terpisah, jacuzzi pribadi, dan butler service 24 jam.', 'Jl. Thamrin No. 10', 'Jakarta', 2500000.00, 4.9, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', 'WiFi, AC, TV, Jacuzzi, Butler, Lounge', 'presidential', 5),
('Standard Room', 'Kamar nyaman untuk budget traveler dengan fasilitas lengkap standar hotel.', 'Jl. Gatot Subroto No. 5', 'Jakarta', 450000.00, 4.5, 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800', 'WiFi, AC, TV', 'standard', 30),
('Family Suite', 'Kamar luas untuk keluarga dengan 2 tempat tidur dan area bermain anak.', 'Jl. Rasuna Said No. 20', 'Jakarta', 1200000.00, 4.7, 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800', 'WiFi, AC, TV, Kids Area, Extra Bed', 'suite', 10),
('Honeymoon Suite', 'Kamar romantis dengan dekorasi khusus dan champagne welcome drink.', 'Jl. Senopati No. 8', 'Jakarta', 1800000.00, 4.9, 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800', 'WiFi, AC, TV, Jacuzzi, Balcony, Flowers', 'suite', 8);

-- =====================================================
-- TABLE 3: RESERVATIONS (Tabel Reservasi/Booking)
-- =====================================================
CREATE TABLE IF NOT EXISTS `reservations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `hotel_id` INT NOT NULL,
    `check_in_date` DATE NOT NULL,
    `check_out_date` DATE NOT NULL,
    `total_nights` INT NOT NULL,
    `total_price` DECIMAL(15, 2) NOT NULL,
    `guest_count` INT DEFAULT 1,
    `special_request` TEXT,
    `status` ENUM('pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled') DEFAULT 'pending',
    `payment_status` ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`hotel_id`) REFERENCES `hotels`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABLE 4: ARTICLES (Tabel Artikel/Berita)
-- =====================================================
CREATE TABLE IF NOT EXISTS `articles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(200) NOT NULL,
    `content` TEXT NOT NULL,
    `excerpt` VARCHAR(500),
    `image_url` VARCHAR(500),
    `author` VARCHAR(100) DEFAULT 'Admin',
    `category` ENUM('news', 'promo', 'tips', 'event') DEFAULT 'news',
    `is_published` TINYINT(1) DEFAULT 1,
    `views` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample articles
INSERT INTO `articles` (`title`, `content`, `excerpt`, `image_url`, `category`) VALUES
('Promo Akhir Tahun 50% OFF!', 'Dapatkan diskon spesial 50% untuk semua tipe kamar selama periode akhir tahun. Promo berlaku untuk booking tanggal 20 Desember 2025 - 5 Januari 2026. Syarat dan ketentuan berlaku.', 'Diskon 50% semua kamar untuk periode akhir tahun!', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', 'promo'),
('Tips Memilih Hotel untuk Liburan Keluarga', 'Memilih hotel yang tepat untuk liburan keluarga sangat penting. Pastikan hotel memiliki fasilitas ramah anak, lokasi strategis, dan ulasan positif dari pengunjung sebelumnya.', 'Panduan lengkap memilih hotel terbaik untuk keluarga.', 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', 'tips'),
('Grand Opening Restaurant Baru!', 'Kami dengan bangga mengumumkan pembukaan restoran baru kami "Sky Dining" di lantai 25. Nikmati pemandangan kota Jakarta yang menakjubkan sambil menikmati hidangan premium.', 'Restaurant baru dengan view spektakuler!', 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800', 'news'),
('Event: Wedding Fair 2026', 'Bergabunglah dengan Wedding Fair 2026 di Grand Hotel. Temukan vendor pernikahan terbaik, dapatkan penawaran eksklusif, dan konsultasi gratis dengan wedding planner profesional.', 'Wedding Fair terbesar di Jakarta!', 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', 'event');

-- =====================================================
-- TABLE 5: FOOD_MENU (Tabel Menu Makanan)
-- =====================================================
CREATE TABLE IF NOT EXISTS `food_menu` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT,
    `price` DECIMAL(12, 2) NOT NULL,
    `category` ENUM('appetizer', 'main_course', 'dessert', 'beverage', 'snack') DEFAULT 'main_course',
    `image_url` VARCHAR(500),
    `is_available` TINYINT(1) DEFAULT 1,
    `is_featured` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample food menu
INSERT INTO `food_menu` (`name`, `description`, `price`, `category`, `image_url`, `is_featured`) VALUES
('Nasi Goreng Seafood', 'Nasi goreng spesial dengan udang, cumi, dan sayuran segar', 85000.00, 'main_course', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800', 1),
('Sate Ayam', 'Sate ayam premium dengan bumbu kacang khas', 65000.00, 'main_course', 'https://images.unsplash.com/photo-1529563021893-cc83c992d28f?w=800', 1),
('Es Teler', 'Minuman segar dengan alpukat, kelapa muda, dan nangka', 35000.00, 'beverage', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=800', 0),
('Chocolate Lava Cake', 'Kue coklat lumer dengan es krim vanilla', 55000.00, 'dessert', 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=800', 1),
('Caesar Salad', 'Salad segar dengan dressing caesar dan crouton', 45000.00, 'appetizer', 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=800', 0);

-- =====================================================
-- CREATE INDEXES FOR BETTER PERFORMANCE
-- =====================================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_hotels_city ON hotels(city);
CREATE INDEX idx_hotels_price ON hotels(price_per_night);
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_articles_category ON articles(category);

-- =====================================================
-- END OF SQL SCRIPT
-- =====================================================
