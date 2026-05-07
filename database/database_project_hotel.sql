-- database_project_hotel.sql
-- Import ke phpMyAdmin atau mysql client
CREATE DATABASE IF NOT EXISTS `project_hotel` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `project_hotel`;

-- roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- users
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role_id` INT NOT NULL DEFAULT 2,
  `api_token` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- hotels
CREATE TABLE IF NOT EXISTS `hotels` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(200) NOT NULL,
  `location` VARCHAR(255),
  `price` DECIMAL(10,2) DEFAULT 0.00,
  `image_url` VARCHAR(255),
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- bookings
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `hotel_id` INT NOT NULL,
  `checkin` DATE,
  `checkout` DATE,
  `status` VARCHAR(50) DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`hotel_id`) REFERENCES `hotels`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- articles
CREATE TABLE IF NOT EXISTS `articles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT,
  `image_url` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- seed roles
INSERT INTO `roles` (`id`, `name`) VALUES (1,'admin'),(2,'user')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- seed users (password = 'password') — replace with actual hashes in production
INSERT INTO `users` (`name`,`email`,`password`,`role_id`) VALUES
('Admin','admin@hotel.com', '$2y$10$........................................',1),
('Aldy','user@hotel.com', '$2y$10$........................................',2)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- seed hotels
INSERT INTO `hotels` (`name`,`location`,`price`,`image_url`,`description`) VALUES
('Grand Sakura Hotel','Bandung',350000.00,'https://example.com/images/hotel1.jpg','Hotel nyaman di pusat kota'),
('Ocean View Inn','Bali',500000.00,'https://example.com/images/hotel2.jpg','Pemandangan laut yang indah')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- seed articles
INSERT INTO `articles` (`title`,`content`,`image_url`) VALUES
('Tips Liburan Aman','Beberapa tips untuk liburan aman...','https://example.com/images/article1.jpg'),
('Promo Bulan Ini','Diskon hingga 20% untuk kamar tertentu','https://example.com/images/article2.jpg')
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- optional: students table + sample student (for UAS credit)
CREATE TABLE IF NOT EXISTS `students` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `student_id` VARCHAR(50) NOT NULL UNIQUE,
  `name` VARCHAR(200) NOT NULL,
  `program` VARCHAR(150),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `students` (`student_id`,`name`,`program`) VALUES
('2023230006','muhammad arya fatthurahman','Teknologi Informasi')
ON DUPLICATE KEY UPDATE name=VALUES(name);
