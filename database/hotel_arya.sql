-- Database: hotel_arya
-- Created by: Muhammad Arya Fatthurahman - 2023230006 - Teknologi Informasi
-- Universitas Darma Persada (Unsada)

CREATE DATABASE IF NOT EXISTS hotel_arya;
USE hotel_arya;

-- Tabel 1: users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nim VARCHAR(20) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    alamat TEXT,
    foto_profil VARCHAR(255) DEFAULT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel 2: rooms
CREATE TABLE rooms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    description TEXT,
    price_per_night DECIMAL(10,2) NOT NULL,
    capacity INT DEFAULT 2,
    facilities TEXT,
    image_url VARCHAR(255),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel 3: bookings
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_nights INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
);

-- Tabel 4: messages (untuk fitur message)
CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'promo', 'notification') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert Admin User (password: admin123)
INSERT INTO users (nim, nama_lengkap, email, password, phone, role) VALUES
('2023230006', 'Muhammad Arya Fatthurahman', 'arya@unsada.ac.id', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '08123456789', 'admin');

-- Insert Sample Rooms
INSERT INTO rooms (room_number, room_type, description, price_per_night, capacity, facilities, image_url) VALUES
('101', 'Deluxe Room', 'Kamar mewah dengan pemandangan kota', 1500000.00, 2, 'AC, TV LED, WiFi, Bathub', 'https://images.unsplash.com/photo-1611892440504-42a792e24d32'),
('102', 'Executive Suite', 'Suite dengan ruang tamu terpisah', 2500000.00, 3, 'AC, TV 50", Kitchenette, Jacuzzi', 'https://images.unsplash.com/photo-1566665797739-1674de7a421a'),
('201', 'Presidential Suite', 'Kamar terbaik hotel dengan semua fasilitas', 5000000.00, 4, 'AC, TV 65", Private Pool, Butler Service', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461'),
('202', 'Family Room', 'Kamar luas untuk keluarga', 3000000.00, 5, 'AC, 2 Bedrooms, TV, Play Area', 'https://images.unsplash.com/photo-1590490360182-c33d57733427');
