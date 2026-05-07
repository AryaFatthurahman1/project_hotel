<?php
// api/endpoints/rooms.php
require_once __DIR__ . '/../config/config.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $hotel_id = $_GET['hotel_id'] ?? null;
    
    if ($hotel_id) {
        $stmt = $conn->prepare("SELECT * FROM rooms WHERE hotel_id = ? AND is_available = 1 ORDER BY room_number");
        $stmt->bind_param("i", $hotel_id);
    } else {
        $stmt = $conn->prepare("SELECT * FROM rooms WHERE is_available = 1 ORDER BY room_number");
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $rooms = [];
    while ($row = $result->fetch_assoc()) {
        $rooms[] = $row;
    }
    
    response_json(true, "Data kamar berhasil diambil", $rooms);
}
?>
