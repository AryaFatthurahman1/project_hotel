<?php
// api/endpoints/bookings.php
require_once __DIR__ . '/../config/config.php';

$user = validate_token($conn);

if (!$user) {
    response_json(false, "Sesi tidak valid. Silakan login kembali.");
}

if ($_SERVER['REQUEST_METHOD'] == 'POST' || $_SERVER['REQUEST_METHOD'] == 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    
    if (!empty($input['room_id']) && !empty($input['check_in']) && !empty($input['check_out'])) {
        $userId = $user['id'];
        $roomId = intval($input['room_id']);
        $checkIn = $input['check_in'];
        $checkOut = $input['check_out'];
        $paymentMethod = $input['payment_method'] ?? "Transfer Bank";
        
        // Hitung total malam
        $checkInDate = new DateTime($checkIn);
        $checkOutDate = new DateTime($checkOut);
        $interval = $checkInDate->diff($checkOutDate);
        $totalNights = $interval->days > 0 ? $interval->days : 1;
        
        // Dapatkan harga kamar
        $roomStmt = $conn->prepare("SELECT price_per_night FROM rooms WHERE id = ?");
        $roomStmt->bind_param("i", $roomId);
        $roomStmt->execute();
        $room = $roomStmt->get_result()->fetch_assoc();
        
        if (!$room) {
            response_json(false, "Kamar tidak ditemukan");
        }
        
        $totalPrice = $room['price_per_night'] * $totalNights;
        
        // Insert booking
        $stmt = $conn->prepare("INSERT INTO bookings (user_id, room_id, check_in, check_out, total_nights, total_price, payment_method, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
        $stmt->bind_param("iissids", $userId, $roomId, $checkIn, $checkOut, $totalNights, $totalPrice, $paymentMethod);
        
        if ($stmt->execute()) {
            // Update status kamar (opsional, tergantung kebijakan hotel)
            $updateStmt = $conn->prepare("UPDATE rooms SET is_available = 0 WHERE id = ?");
            $updateStmt->bind_param("i", $roomId);
            $updateStmt->execute();
            
            response_json(true, "Pemesanan berhasil dibuat", [
                "booking_id" => $conn->insert_id,
                "total_price" => $totalPrice,
                "total_nights" => $totalNights
            ]);
        } else {
            response_json(false, "Pemesanan gagal: " . $conn->error);
        }
    } else {
        response_json(false, "Data pemesanan tidak lengkap");
    }
}

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // List bookings for current user
    $stmt = $conn->prepare("SELECT b.*, r.room_number, r.room_type, h.name as hotel_name FROM bookings b JOIN rooms r ON b.room_id = r.id JOIN hotels h ON r.hotel_id = h.id WHERE b.user_id = ? ORDER BY b.created_at DESC");
    $stmt->bind_param("i", $user['id']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $bookings = [];
    while ($row = $result->fetch_assoc()) {
        $bookings[] = $row;
    }
    
    response_json(true, "Data pemesanan berhasil diambil", $bookings);
}
?>
