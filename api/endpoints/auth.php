<?php
require_once '../config/config.php';

// Ambil token dari header atau POST/JSON body
$headers = getallheaders();
$token = null;

if (!empty($headers['Authorization']) && preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $m)) {
    $token = $m[1];
}

if (!$token) {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $token = $input['token'] ?? null;
}

if (!$token) {
    response_json(false, 'Token diperlukan');
}

$stmt = $conn->prepare("SELECT u.id, u.nim, u.nama_lengkap, u.email, u.role, u.phone, u.alamat, u.foto_profil FROM users u WHERE u.api_token = ? LIMIT 1");
$stmt->bind_param("s", $token);
$stmt->execute();
$result = $stmt->get_result();
$user = $result ? $result->fetch_assoc() : null;

if (!$user) {
    response_json(false, 'Token tidak valid');
}

response_json(true, 'Berhasil autentikasi', $user);

$stmt->close();
$conn->close();
?>
