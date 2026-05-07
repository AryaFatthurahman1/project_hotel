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

    case 'food_menu':
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT * FROM food_menu WHERE id = ?");
            $stmt->bind_param("i", $id);
        } else {
            $stmt = $conn->prepare("SELECT * FROM food_menu ORDER BY category ASC, name ASC");
        }
        break;
        
    case 'bookings':
    case 'reservations':
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT r.*, r.check_in_date as check_in, r.check_out_date as check_out, h.name as hotel_name, h.address as hotel_location, h.image_url as hotel_image 
                                   FROM reservations r 
                                   JOIN hotels h ON r.hotel_id = h.id 
                                   WHERE r.id = ?");
            $stmt->bind_param("i", $id);
        } elseif (!empty($user_id)) {
            $stmt = $conn->prepare("SELECT r.*, r.check_in_date as check_in, r.check_out_date as check_out, h.name as hotel_name, h.address as hotel_location, h.image_url as hotel_image 
                                   FROM reservations r 
                                   JOIN hotels h ON r.hotel_id = h.id 
                                   WHERE r.user_id = ? 
                                   ORDER BY r.created_at DESC");
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