<?php
// api/endpoints/auth.php
require_once __DIR__ . '/../config/config.php';

$user = validate_token($conn);

if (!$user) {
    response_json(false, 'Token tidak valid atau tidak ditemukan');
}

response_json(true, 'Berhasil autentikasi', $user);

$conn->close();
?>
