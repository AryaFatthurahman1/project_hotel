-- Database: hotel_arya
-- Updated for: The Emerald Imperial Luxury System
-- Author: Muhammad Arya Fatthurahman

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- Tabel: users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nim` varchar(20) DEFAULT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `foto_profil` varchar(255) DEFAULT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `api_token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data Awal Users (Password: 123)
-- Menggunakan INSERT IGNORE untuk menghindari error duplicate entry
INSERT IGNORE INTO `users` (`nama_lengkap`, `email`, `password`, `role`, `api_token`) VALUES
('Muhammad Arya Fatthurahman', 'aryafatthurahman4@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'MASTER_ADMIN_BYPASS_TOKEN'),
('Admin Hotel', 'admin@emerald.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'ADMIN_TOKEN_123');

-- Tabel: hotels
CREATE TABLE IF NOT EXISTS `hotels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `location` varchar(255) NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `stars` decimal(2,1) DEFAULT 4.0,
  `description` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `facilities` varchar(255) DEFAULT 'WiFi,AC,Pool,Gym',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bersihkan data hotel lama agar bisa memasukkan data baru yang lebih menarik
TRUNCATE TABLE `hotels`;

INSERT INTO `hotels` (`name`, `location`, `price`, `stars`, `description`, `image_url`, `facilities`) VALUES
('The Emerald Imperial', 'Jakarta Selatan, Indonesia', 2500000.00, 5.0, 'Pengalaman menginap paling mewah di jantung kota Jakarta dengan pelayanan butler 24 jam.', 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80', 'WiFi,AC,Pool,Gym,Spa,Parking'),
('Sapphire Garden Resort', 'Bali, Indonesia', 1850000.00, 4.5, 'Resort tepi pantai dengan pemandangan sunset yang menakjubkan dan taman tropis yang luas.', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&q=80', 'WiFi,Pool,Beach Access,Restaurant'),
('Ruby City Boutique', 'Bandung, Indonesia', 950000.00, 4.0, 'Hotel butik dengan desain unik dan lokasi strategis dekat dengan pusat perbelanjaan.', 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80', 'WiFi,AC,Cafe,Laundry'),
('Diamond Mountain Retreat', 'Puncak, Bogor', 1200000.00, 4.2, 'Udara segar pegunungan dan ketenangan yang tidak tertandingi untuk liburan keluarga.', 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&q=80', 'WiFi,AC,Garden,Kid Zone'),
('Crystal Waterfront', 'Surabaya, Indonesia', 1100000.00, 4.3, 'Hotel modern dengan pemandangan pelabuhan yang ikonik dan akses mudah ke pusat bisnis.', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80', 'WiFi,AC,Pool,Meeting Room'),
('Golden Sand Villas', 'Lombok, Indonesia', 3200000.00, 5.0, 'Villa eksklusif dengan kolam renang pribadi dan akses langsung ke pantai pasir putih.', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&q=80', 'Private Pool,Beach,WiFi,Butler'),
('Onyx Executive Suites', 'Medan, Indonesia', 850000.00, 4.0, 'Hunian nyaman untuk pebisnis dengan fasilitas lengkap dan kecepatan internet tinggi.', 'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?auto=format&fit=crop&q=80', 'WiFi,AC,Gym,Business Center');

-- Tabel: articles
CREATE TABLE IF NOT EXISTS `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` varchar(50) DEFAULT 'Travel',
  `content` text DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bersihkan data artikel lama
TRUNCATE TABLE `articles`;

INSERT INTO `articles` (`title`, `category`, `content`, `image_url`) VALUES
('Tips Traveling Hemat di Tahun 2026', 'Travel Tips', 'Traveling tidak harus mahal. Dengan perencanaan yang matang dan pemilihan waktu yang tepat, Anda bisa menikmati liburan mewah tanpa harus menguras kantong. Gunakan aplikasi The Emerald Imperial untuk mendapatkan harga terbaik.', 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?auto=format&fit=crop&q=80'),
('5 Destinasi Hits di Jakarta', 'Destinasi', 'Jakarta tidak hanya tentang kemacetan. Temukan hidden gems di Jakarta Selatan yang sangat Instagramable dan seru untuk dikunjungi bersama teman atau pasangan Anda akhir pekan ini.', 'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?auto=format&fit=crop&q=80'),
('Promo Emerald Imperial Bulan Ini', 'Promo', 'Dapatkan diskon eksklusif hingga 40% untuk pemesanan melalui aplikasi mobile The Emerald Imperial selama periode Januari. Jangan lewatkan kesempatan menginap di suite termewah kami.', 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&q=80'),
('Cara Memilih Hotel yang Aman', 'Safety', 'Keamanan adalah prioritas utama saat menginap. Pastikan hotel pilihan Anda memiliki protokol keamanan yang baik, akses kartu kunci, dan staf yang responsif 24 jam.', 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&q=80'),
('Wisata Kuliner Terbaik di Bali', 'Culinary', 'Bali bukan hanya soal pantai. Nikmati berbagai hidangan lezat mulai dari ayam betutu hingga seafood segar di tepi Jimbaran. Kami merangkum 10 tempat makan wajib coba.', 'https://images.unsplash.com/photo-1537047902294-62a40c20a670?auto=format&fit=crop&q=80');

-- Tabel: bookings
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `hotel_id` int(11) NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `total_price` decimal(15,2) NOT NULL,
  `status` enum('pending','confirmed','cancelled','completed') DEFAULT 'pending',
  `qr_code` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tambahkan data pesanan awal untuk demo
INSERT IGNORE INTO `bookings` (`user_id`, `hotel_id`, `check_in`, `check_out`, `total_price`, `status`, `qr_code`) VALUES 
(1, 1, '2026-02-01', '2026-02-03', 5000000.00, 'confirmed', 'HEI-101-ABC');

COMMIT;
