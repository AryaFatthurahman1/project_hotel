<?php
// api/endpoints/get_data.php
require_once __DIR__ . '/../config/config.php';

// Ambil parameter
$table = $_GET['table'] ?? '';
$id = $_GET['id'] ?? '';

// Validasi
if (empty($table)) {
    response_json(false, 'Table parameter required');
}

// Query berdasarkan tabel
switch ($table) {
    case 'hotels':
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT * FROM hotels WHERE id = ?");
            $stmt->bind_param("i", $id);
        } else {
            $stmt = $conn->prepare("SELECT * FROM hotels ORDER BY created_at DESC");
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
        // Untuk bookings, butuh user_id (dari auth)
        $user_id = $_GET['user_id'] ?? '';
        if (!empty($id)) {
            $stmt = $conn->prepare("SELECT b.*, h.name as hotel_name FROM bookings b JOIN hotels h ON b.hotel_id = h.id WHERE b.id = ?");
            $stmt->bind_param("i", $id);
        } elseif (!empty($user_id)) {
            $stmt = $conn->prepare("SELECT b.*, h.name as hotel_name FROM bookings b JOIN hotels h ON b.hotel_id = h.id WHERE b.user_id = ? ORDER BY b.created_at DESC");
            $stmt->bind_param("i", $user_id);
        } else {
            response_json(false, 'User ID required for bookings');
        }
        break;
        
    default:
        response_json(false, 'Invalid table name');
}

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    response_json(true, 'Data retrieved successfully', $data);
} else {
    response_json(false, 'Query failed: ' . $conn->error);
}

$stmt->close();
$conn->close();
?>