<?php
// api/endpoints/insert_data.php
require_once __DIR__ . '/../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') response_json(false, 'Method not allowed');

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$type = $input['type'] ?? ($input['table'] ?? ''); // handle both 'type' and 'table' keys

// simple token check for protected inserts
$token = $input['token'] ?? null;
if (!$token) response_json(false, 'Token required to perform this action');

// Check token with mysqli
$stmt = $conn->prepare("SELECT id, role FROM users WHERE api_token = ? LIMIT 1");
$stmt->bind_param("s", $token);
$stmt->execute();
$u = $stmt->get_result()->fetch_assoc();

if (!$u) response_json(false, 'Session expired or invalid token. Please re-login.');

// --- Handle INSERT Types ---

if ($type === 'booking' || $type === 'bookings') {
    $hotel_id = intval($input['hotel_id'] ?? 0);
    $checkin = $input['check_in'] ?? ($input['checkin'] ?? null);
    $checkout = $input['check_out'] ?? ($input['checkout'] ?? null);
    $total_price = floatval($input['total_price'] ?? 0);
    $qr_code = "HEI-" . rand(100, 999) . "-" . strtoupper(substr(md5(time()), 0, 5));

    if (!$hotel_id || !$checkin || !$checkout) response_json(false, 'hotel_id, check_in, and check_out keys are required');
    
    $ins = $conn->prepare("INSERT INTO bookings (user_id, hotel_id, check_in, check_out, total_price, status, qr_code) VALUES (?, ?, ?, ?, ?, 'confirmed', ?)");
    $ins->bind_param("iissds", $u['id'], $hotel_id, $checkin, $checkout, $total_price, $qr_code);
    
    if ($ins->execute()) {
        response_json(true, 'Booking successful. Your stay is confirmed.', ['booking_id' => $conn->insert_id, 'qr_code' => $qr_code]);
    } else {
        response_json(false, 'Database error during booking: ' . $conn->error);
    }
}

if ($type === 'hotel' || $type === 'hotels') {
    if ($u['role'] !== 'admin') response_json(false, 'Unauthorized. Admin access required.');

    $name = trim($input['name'] ?? '');
    if ($name === '') response_json(false, 'Hotel name is required');
    
    $location = $input['location'] ?? null;
    $price = $input['price'] ?? 0;
    $stars = $input['stars'] ?? 4.0;
    $facil = $input['facilities'] ?? 'WiFi,AC,Pool';
    $img = $input['image_url'] ?? null;
    $desc = $input['description'] ?? null;

    $ins = $conn->prepare("INSERT INTO hotels (name, location, price, stars, facilities, image_url, description) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $ins->bind_param("ssddsss", $name, $location, $price, $stars, $facil, $img, $desc);
    
    if ($ins->execute()) {
        response_json(true, 'Hotel listing created successfully', ['hotel_id' => $conn->insert_id]);
    } else {
        response_json(false, 'Failed to create hotel: ' . $conn->error);
    }
}

response_json(false, "Invalid operation type: '$type'");
?>
