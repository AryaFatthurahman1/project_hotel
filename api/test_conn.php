<?php
// api/test_conn.php
require_once 'config/config.php';

echo json_encode([
    'status' => true,
    'message' => 'Koneksi API Berhasil!',
    'environment' => ($_SERVER['SERVER_NAME'] === 'localhost') ? 'Local' : 'Production',
    'database' => $conn ? 'Connected to ' . $conn->host_info : 'Disconnected',
    'server_time' => date('Y-m-d H:i:s'),
    'uri' => $_SERVER['REQUEST_URI']
]);
?>
