<?php
// api/endpoints/update_data.php
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
    
    $fields = [];
    $types = "";
    $vals = [];

    if (isset($input['name'])) { $fields[] = 'name = ?'; $types .= "s"; $vals[] = $input['name']; }
    if (isset($input['location'])) { $fields[] = 'location = ?'; $types .= "s"; $vals[] = $input['location']; }
    if (isset($input['price'])) { $fields[] = 'price = ?'; $types .= "d"; $vals[] = $input['price']; }
    
    if (empty($fields)) response_json(false, 'Nothing to update');
    
    $sql = "UPDATE hotels SET " . implode(', ', $fields) . " WHERE id = ?";
    $types .= "i";
    $vals[] = $id;

    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$vals);
    
    if ($stmt->execute()) {
        response_json(true, 'Hotel updated');
    } else {
        response_json(false, 'Update failed: ' . $conn->error);
    }
}

if ($type === 'booking_status') {
    $id = intval($input['id'] ?? 0);
    $status = $input['status'] ?? null;
    if (!$id || !$status) response_json(false, 'id and status required');
    
    // allow admin or owner to change status
    if ($u['role'] !== 'admin') {
        $chk = $conn->prepare("SELECT user_id FROM bookings WHERE id = ? LIMIT 1");
        $chk->bind_param("i", $id);
        $chk->execute();
        $owner = $chk->get_result()->fetch_assoc();
        if ($owner['user_id'] != $u['id']) response_json(false, 'Unauthorized');
    }
    
    $upd = $conn->prepare("UPDATE bookings SET status = ? WHERE id = ?");
    $upd->bind_param("si", $status, $id);
    
    if ($upd->execute()) {
        response_json(true, 'Booking status updated');
    } else {
        response_json(false, 'Update failed: ' . $conn->error);
    }
}

response_json(false, 'Invalid type');
?>
