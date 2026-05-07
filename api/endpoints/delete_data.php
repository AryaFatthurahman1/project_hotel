<?php
// api/endpoints/delete_data.php
require_once __DIR__ . '/../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') response_json(false, 'Method not allowed');

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$type = $input['type'] ?? '';
$token = $input['token'] ?? null;

if (!$token) response_json(false, 'Token required');

// Check token
$stmt = $conn->prepare("SELECT id, role FROM users WHERE api_token = ? LIMIT 1");
$stmt->bind_param("s", $token);
$stmt->execute();
$u = $stmt->get_result()->fetch_assoc();

if (!$u) response_json(false, 'Invalid token');

if ($type === 'hotel') {
    if ($u['role'] !== 'admin') response_json(false, 'Unauthorized');
    $id = intval($input['id'] ?? 0);
    if (!$id) response_json(false, 'id required');
    
    $del = $conn->prepare("DELETE FROM hotels WHERE id = ?");
    $del->bind_param("i", $id);
    
    if ($del->execute()) {
        response_json(true, 'Hotel deleted');
    } else {
        response_json(false, 'Delete failed: ' . $conn->error);
    }
}

if ($type === 'booking') {
    $id = intval($input['id'] ?? 0);
    if (!$id) response_json(false, 'id required');
    
    // owner or admin
    $chk = $conn->prepare("SELECT user_id FROM bookings WHERE id = ? LIMIT 1");
    $chk->bind_param("i", $id);
    $chk->execute();
    $owner = $chk->get_result()->fetch_assoc();
    
    if ($u['role'] !== 'admin' && $owner['user_id'] != $u['id']) response_json(false, 'Unauthorized');
    
    $del = $conn->prepare("DELETE FROM bookings WHERE id = ?");
    $del->bind_param("i", $id);
    
    if ($del->execute()) {
        response_json(true, 'Booking deleted');
    } else {
        response_json(false, 'Delete failed: ' . $conn->error);
    }
}

response_json(false, 'Invalid type');
?>
