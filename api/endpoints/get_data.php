<?php
// api/endpoints/get_data.php
require_once __DIR__ . '/../config/config.php';

// Ambil parameter
$table = $_GET['table'] ?? '';
$id = $_GET['id'] ?? '';
$user_id = $_GET['user_id'] ?? '';

// Validasi
if (empty($table)) response_json(false, 'Parameter "table" diperlukan');

// Query berdasarkan tabel
switch ($table) {
    case 'hotels':
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT * FROM hotels WHERE id = ?");
            $stmt->bind_param("i", $id);
        } else {
            $stmt = $conn->prepare("SELECT * FROM hotels ORDER BY stars DESC, id DESC");
        }
        break;
        
    case 'articles':
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT * FROM articles WHERE id = ?");
            $stmt->bind_param("i", $id);
        } else {
            $stmt = $conn->prepare("SELECT * FROM articles ORDER BY created_at DESC");
        }
        break;
        
    case 'bookings':
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT b.*, h.name as hotel_name, h.location as hotel_location, h.image_url as hotel_image 
                                  FROM bookings b 
                                  JOIN hotels h ON b.hotel_id = h.id 
                                  WHERE b.id = ?");
            $stmt->bind_param("i", $id);
        } elseif (!empty($user_id)) {
            $stmt = $conn->prepare("SELECT b.*, h.name as hotel_name, h.location as hotel_location, h.image_url as hotel_image 
                                  FROM bookings b 
                                  JOIN hotels h ON b.hotel_id = h.id 
                                  WHERE b.user_id = ? 
                                  ORDER BY b.created_at DESC");
            $stmt->bind_param("i", $user_id);
        } else {
            response_json(false, 'User ID diperlukan untuk melihat riwayat pesanan');
        }
        break;
        
    default:
        response_json(false, "Tabel '$table' tidak valid");
}

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    response_json(true, 'Data berhasil diambil', $data);
} else {
    response_json(false, 'Gagal mengambil data: ' . $conn->error);
}

$stmt->close();
$conn->close();
?>