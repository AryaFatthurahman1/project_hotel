<?php
/**
 * THE EMERALD IMPERIAL - ULTIMATE ROUTER
 * Dibuat oleh: Muhammad Arya Fatthurahman
 */

// 1. Konfigurasi Error
error_reporting(E_ALL);
ini_set('display_errors', 0);

// 2. Global Headers (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 3. Deteksi Path
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
// Jika di subfolder /api/, bersihkan
$uri = str_replace('/api/', '/', $uri);
$uri = trim($uri, '/');

// 4. Deteksi Browser vs API
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
$isApp = (strpos($userAgent, 'Flutter') !== false || strpos($userAgent, 'dart') !== false);
$acceptJson = (strpos($_SERVER['HTTP_ACCEPT'] ?? '', 'application/json') !== false);

// 5. ROUTING UTAMA
if (empty($uri)) {
    // Jika akses root domain (https://arya.bersama.cloud/)
    if ($isApp || $acceptJson) {
        header("Content-Type: application/json");
        echo json_encode([
            'status' => true,
            'message' => 'The Emerald Imperial API is Online',
            'version' => '1.3.0',
            'author' => 'Muhammad Arya Fatthurahman'
        ]);
        exit();
    } else {
        // Tampilkan landing page untuk pengunjung web
        if (file_exists('landing.php')) {
            require_once 'landing.php';
        } else {
            echo "<h1>The Emerald Imperial</h1><p>Luxury Hotel System Online</p>";
        }
        exit();
    }
}

// 6. ENDPOINT ROUTING
header("Content-Type: application/json");

// Normalisasikan endpoint (hapus .php jika ada)
$endpoint = str_replace('.php', '', $uri);

switch ($endpoint) {
    case 'login':
        require_once 'endpoints/login.php';
        break;
    case 'register':
        require_once 'endpoints/register.php';
        break;
    case 'auth':
        require_once 'endpoints/auth.php';
        break;
    case 'profile':
        require_once 'endpoints/profile.php';
        break;
    case 'rooms':
        require_once 'endpoints/rooms.php';
        break;
    case 'bookings':
        require_once 'endpoints/bookings.php';
        break;
    case 'get_data':
        require_once 'endpoints/get_data.php';
        break;
    case 'insert_data':
        require_once 'endpoints/insert_data.php';
        break;
    case 'update_data':
        require_once 'endpoints/update_data.php';
        break;
    case 'delete_data':
        require_once 'endpoints/delete_data.php';
        break;
    case 'test':
        require_once 'tests/test.php';
        break;
    default:
        http_response_code(200); // Selalu 200 agar Flutter tidak crash, tapi status false
        echo json_encode([
            'status' => false,
            'message' => "Endpoint '$uri' tidak ditemukan",
            'available' => ['login', 'register', 'rooms', 'bookings', 'profile']
        ]);
        break;
}
?>
