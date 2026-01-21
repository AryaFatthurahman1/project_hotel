<?php
// api/update_data.php
require_once 'config.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') response_json(false, 'Method not allowed');
$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$type = $input['type'] ?? '';
$token = $input['token'] ?? null;
if (!$token) response_json(false, 'Token required');
$stmt = $pdo->prepare("SELECT id, role_id FROM users WHERE api_token = :token LIMIT 1");
$stmt->execute(['token' => $token]);
$u = $stmt->fetch();
if (!$u) response_json(false, 'Invalid token');

if ($type === 'hotel') {
  if ($u['role_id'] != 1) response_json(false, 'Unauthorized');
  $id = intval($input['id'] ?? 0);
  if (!$id) response_json(false, 'id required');
  $fields = [];
  $params = ['id'=>$id];
  if (isset($input['name'])) { $fields[] = 'name = :name'; $params['name']=$input['name']; }
  if (isset($input['location'])) { $fields[] = 'location = :location'; $params['location']=$input['location']; }
  if (isset($input['price'])) { $fields[] = 'price = :price'; $params['price']=$input['price']; }
  if (empty($fields)) response_json(false, 'Nothing to update');
  $sql = "UPDATE hotels SET " . implode(', ', $fields) . " WHERE id = :id";
  $pdo->prepare($sql)->execute($params);
  response_json(true, 'Hotel updated');
}

if ($type === 'booking_status') {
  $id = intval($input['id'] ?? 0);
  $status = $input['status'] ?? null;
  if (!$id || !$status) response_json(false, 'id and status required');
  // allow admin or owner to change status
  if ($u['role_id'] != 1) {
    $chk = $pdo->prepare("SELECT user_id FROM bookings WHERE id = :id LIMIT 1");
    $chk->execute(['id'=>$id]);
    $owner = $chk->fetchColumn();
    if ($owner != $u['id']) response_json(false, 'Unauthorized');
  }
  $pdo->prepare("UPDATE bookings SET status = :s WHERE id = :id")->execute(['s'=>$status,'id'=>$id]);
  response_json(true, 'Booking status updated');
}

response_json(false, 'Invalid type');
