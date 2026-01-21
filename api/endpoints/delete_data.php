<?php
// api/delete_data.php
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
  $pdo->prepare("DELETE FROM hotels WHERE id = :id")->execute(['id'=>$id]);
  response_json(true, 'Hotel deleted');
}

if ($type === 'booking') {
  $id = intval($input['id'] ?? 0);
  if (!$id) response_json(false, 'id required');
  // owner or admin
  $chk = $pdo->prepare("SELECT user_id FROM bookings WHERE id = :id LIMIT 1");
  $chk->execute(['id'=>$id]);
  $owner = $chk->fetchColumn();
  if ($u['role_id'] != 1 && $owner != $u['id']) response_json(false, 'Unauthorized');
  $pdo->prepare("DELETE FROM bookings WHERE id = :id")->execute(['id'=>$id]);
  response_json(true, 'Booking deleted');
}

response_json(false, 'Invalid type');
