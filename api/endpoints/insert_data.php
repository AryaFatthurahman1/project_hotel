<?php
// api/insert_data.php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') response_json(false, 'Method not allowed');

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$type = $input['type'] ?? '';

// simple token check for protected inserts
$token = $input['token'] ?? null;
if (!$token) response_json(false, 'Token required');
$stmt = $pdo->prepare("SELECT id FROM users WHERE api_token = :token LIMIT 1");
$stmt->execute(['token' => $token]);
$u = $stmt->fetch();
if (!$u) response_json(false, 'Invalid token');

if ($type === 'booking') {
    $hotel_id = intval($input['hotel_id'] ?? 0);
    $checkin = $input['checkin'] ?? null;
    $checkout = $input['checkout'] ?? null;
    if (!$hotel_id || !$checkin || !$checkout) response_json(false, 'hotel_id, checkin, checkout required');
    $ins = $pdo->prepare("INSERT INTO bookings (user_id, hotel_id, checkin, checkout, status) VALUES (:uid, :hid, :ci, :co, 'pending')");
    $ins->execute(['uid' => $u['id'], 'hid' => $hotel_id, 'ci' => $checkin, 'co' => $checkout]);
    response_json(true, 'Booking created', ['booking_id' => $pdo->lastInsertId()]);
}

if ($type === 'hotel') {
    // only admin should insert hotels — simple check
    $roleStmt = $pdo->prepare("SELECT role_id FROM users WHERE id = :id LIMIT 1");
    $roleStmt->execute(['id' => $u['id']]);
    $role = $roleStmt->fetchColumn();
    if ($role != 1) response_json(false, 'Unauthorized');

    $name = trim($input['name'] ?? '');
    if ($name === '') response_json(false, 'Name required');
    $ins = $pdo->prepare("INSERT INTO hotels (name, location, price, image_url, description) VALUES (:n, :loc, :p, :img, :desc)");
    $ins->execute(['n'=>$name,'loc'=>$input['location'] ?? null,'p'=>$input['price'] ?? 0,'img'=>$input['image_url'] ?? null,'desc'=>$input['description'] ?? null]);
    response_json(true, 'Hotel created', ['hotel_id' => $pdo->lastInsertId()]);
}

response_json(false, 'Invalid type');
