<?php
// api/endpoints/insert_data.php
require_once __DIR__ . '/../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') response_json(false, 'Method not allowed');

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$type = $input['type'] ?? ($input['table'] ?? ''); 

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

if ($type === 'booking' || $type === 'bookings' || $type === 'reservation' || $type === 'reservations') {
    $hotel_id = intval($input['hotel_id'] ?? 0);
    $checkin = $input['check_in'] ?? ($input['checkin'] ?? null);
    $checkout = $input['check_out'] ?? ($input['checkout'] ?? null);
    $total_price = floatval($input['total_price'] ?? 0);
    $qr_code = "HEI-" . rand(100, 999) . "-" . strtoupper(substr(md5(time()), 0, 5));

    if (!$hotel_id || !$checkin || !$checkout) {
        response_json(false, 'hotel_id, check_in, and check_out are required');
    }
    
    // Calculate total nights if not provided
    $d1 = new DateTime($checkin);
    $d2 = new DateTime($checkout);
    $total_nights = $d1->diff($d2)->days;
    if ($total_nights <= 0) $total_nights = 1;

    $ins = $conn->prepare("INSERT INTO reservations (user_id, hotel_id, check_in_date, check_out_date, total_nights, total_price, status, qr_code) VALUES (?, ?, ?, ?, ?, ?, 'confirmed', ?)");
    $ins->bind_param("iissdds", $u['id'], $hotel_id, $checkin, $checkout, $total_nights, $total_price, $qr_code);
    
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
    
    $address = $input['address'] ?? ($input['location'] ?? '');
    $city = $input['city'] ?? 'Jakarta';
    $price = $input['price_per_night'] ?? ($input['price'] ?? 0);
    $stars = $input['stars'] ?? ($input['rating'] ?? 4.0);
    $facil = $input['facilities'] ?? 'WiFi,AC,Pool';
    $img = $input['image_url'] ?? '';
    $desc = $input['description'] ?? '';

    $ins = $conn->prepare("INSERT INTO hotels (name, address, city, price_per_night, rating, facilities, image_url, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $ins->bind_param("sssddsss", $name, $address, $city, $price, $stars, $facil, $img, $desc);
    
    if ($ins->execute()) {
        response_json(true, 'Hotel listing created successfully', ['hotel_id' => $conn->insert_id]);
    } else {
        response_json(false, 'Failed to create hotel: ' . $conn->error);
    }
}

response_json(false, "Invalid operation type: '$type'");
?>
