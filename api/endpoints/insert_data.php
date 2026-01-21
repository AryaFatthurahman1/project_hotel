<?php
// api/endpoints/insert_data.php
require_once __DIR__ . '/../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') response_json(false, 'Method not allowed');

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$type = $input['type'] ?? '';

// simple token check for protected inserts
$token = $input['token'] ?? null;
if (!$token) response_json(false, 'Token required');

// Check token with mysqli
$stmt = $conn->prepare("SELECT id, role FROM users WHERE api_token = ? LIMIT 1");
$stmt->bind_param("s", $token);
$stmt->execute();
$u = $stmt->get_result()->fetch_assoc();

if (!$u) response_json(false, 'Invalid token');

if ($type === 'booking') {
    $hotel_id = intval($input['hotel_id'] ?? 0);
    $checkin = $input['checkin'] ?? null;
    $checkout = $input['checkout'] ?? null;
    if (!$hotel_id || !$checkin || !$checkout) response_json(false, 'hotel_id, checkin, checkout required');
    
    $ins = $conn->prepare("INSERT INTO bookings (user_id, hotel_id, checkin, checkout, status) VALUES (?, ?, ?, ?, 'pending')");
    $ins->bind_param("iiss", $u['id'], $hotel_id, $checkin, $checkout);
    
    if ($ins->execute()) {
        response_json(true, 'Booking created', ['booking_id' => $conn->insert_id]);
    } else {
        response_json(false, 'Failed to create booking: ' . $conn->error);
    }
}

if ($type === 'hotel') {
    // only admin should insert hotels
    if ($u['role'] !== 'admin') response_json(false, 'Unauthorized');

    $name = trim($input['name'] ?? '');
    if ($name === '') response_json(false, 'Name required');
    
    $location = $input['location'] ?? null;
    $price = $input['price'] ?? 0;
    $image_url = $input['image_url'] ?? null;
    $description = $input['description'] ?? null;

    $ins = $conn->prepare("INSERT INTO hotels (name, location, price, image_url, description) VALUES (?, ?, ?, ?, ?)");
    $ins->bind_param("ssdss", $name, $location, $price, $image_url, $description);
    
    if ($ins->execute()) {
        response_json(true, 'Hotel created', ['hotel_id' => $conn->insert_id]);
    } else {
        response_json(false, 'Failed to create hotel: ' . $conn->error);
    }
}

response_json(false, 'Invalid type');
?>
