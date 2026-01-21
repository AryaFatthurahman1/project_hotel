<?php
require_once 'config.php';

$database = new Database();
$conn = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user = validateToken($conn);
    $data = json_decode(file_get_contents("php://input"));
    
    if (!empty($data->room_id) && !empty($data->check_in) && !empty($data->check_out)) {
        $userId = $user['id'];
        $roomId = $data->room_id;
        $checkIn = $data->check_in;
        $checkOut = $data->check_out;
        $paymentMethod = isset($data->payment_method) ? $data->payment_method : "Transfer Bank";
        
        // Hitung total malam
        $checkInDate = new DateTime($checkIn);
        $checkOutDate = new DateTime($checkOut);
        $interval = $checkInDate->diff($checkOutDate);
        $totalNights = $interval->days;
        
        // Dapatkan harga kamar
        $roomQuery = "SELECT price_per_night FROM rooms WHERE id = ?";
        $roomStmt = $conn->prepare($roomQuery);
        $roomStmt->bind_param("i", $roomId);
        $roomStmt->execute();
        $roomResult = $roomStmt->get_result();
        $room = $roomResult->fetch_assoc();
        
        $totalPrice = $room['price_per_night'] * $totalNights;
        
        // Insert booking
        $query = "INSERT INTO bookings (user_id, room_id, check_in, check_out, 
                  total_nights, total_price, payment_method) 
                  VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("iissids", $userId, $roomId, $checkIn, $checkOut, 
                         $totalNights, $totalPrice, $paymentMethod);
        
        if ($stmt->execute()) {
            // Update status kamar
            $updateRoom = "UPDATE rooms SET is_available = 0 WHERE id = ?";
            $updateStmt = $conn->prepare($updateRoom);
            $updateStmt->bind_param("i", $roomId);
            $updateStmt->execute();
            
            responseJSON("success", "Pemesanan berhasil dibuat", [
                "booking_id" => $stmt->insert_id,
                "total_price" => $totalPrice,
                "total_nights" => $totalNights
            ]);
        } else {
            responseJSON("error", "Pemesanan gagal: " . $conn->error);
        }
    } else {
        responseJSON("error", "Data pemesanan tidak lengkap");
    }
}
?>
