<?php
/**
 * THE EMERALD IMPERIAL - ROBUST ROUTER V3
 * Dibuat oleh: Muhammad Arya Fatthurahman
 */

// 1. Error Prevention & Logging
error_reporting(E_ALL);
ini_set('display_errors', 0); 
date_default_timezone_set('Asia/Jakarta');

// 2. Security Headers (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 3. Robust Route Detection
// Coba ambil URI dari berbagai kemungkinan (Apache/cPanel variables)
$uri = $_SERVER['REQUEST_URI'] ?? '/';
if (isset($_SERVER['REDIRECT_URL'])) { $uri = $_SERVER['REDIRECT_URL']; }
if (isset($_SERVER['PATH_INFO'])) { $uri = $_SERVER['PATH_INFO']; }

// Bersihkan URI dari query string dan slashes
$uri = parse_url($uri, PHP_URL_PATH);
$uri = trim($uri, '/');

// Jika project berada di subfolder (misal: /api/login)
if (strpos($uri, 'api/') === 0) {
    $uri = substr($uri, 4);
}

// Identifikasi Client
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
$isApp = (strpos($userAgent, 'Flutter') !== false || strpos($_SERVER['HTTP_ACCEPT'] ?? '', 'json') !== false);

// 4. ROUTING UTAMA

// Halaman Dasar (Landing atau API Status)
if (empty($uri)) {
    if (!$isApp) {
        if (file_exists('landing.php')) {
            require_once 'landing.php';
        } else {
            echo "<div style='font-family:sans-serif; text-align:center; padding:100px; background:#0f1b14; color:#d4af37; min-height:100vh;'>";
            echo "<h1>THE EMERALD IMPERIAL</h1>";
            echo "<p style='color:white;'>Luxury Hotel System API is Online.</p>";
            echo "<a href='admin' style='color:#d4af37; text-decoration:none; border:1px solid #d4af37; padding:10px 20px; border-radius:5px;'>ADMIN DASHBOARD</a>";
            echo "</div>";
        }
    } else {
        header("Content-Type: application/json");
        echo json_encode(['status' => true, 'message' => 'API Emerald Imperial Aktif', 'version' => '3.0.0']);
    }
    exit();
}

// Web Admin Route
if ($uri === 'admin') {
    if (file_exists('admin/index.html')) {
        readfile('admin/index.html');
        exit();
    }
}

// 5. HELPER RESPONSE
function sendResponse($status, $message, $data = null) {
    header("Content-Type: application/json");
    echo json_encode([
        'status' => $status,
        'message' => $message,
        'data' => $data,
        'server_time' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT);
    exit();
}

// 6. ENDPOINT MAPPING (Tanpa extension .php)
$endpoints = [
    'login' => 'endpoints/login.php',
    'register' => 'endpoints/register.php',
    'profile' => 'endpoints/profile.php',
    'get_data' => 'endpoints/get_data.php',
    'insert_data' => 'endpoints/insert_data.php',
    'update_data' => 'endpoints/update_data.php',
    'delete_data' => 'endpoints/delete_data.php',
    'test' => 'tests/test.php'
];

if (isset($endpoints[$uri])) {
    $targetFile = __DIR__ . '/' . $endpoints[$uri];
    if (file_exists($targetFile)) {
        require_once $targetFile;
        exit();
    } else {
        sendResponse(false, "File endpoint '$uri' tidak ditemukan di server.");
    }
}

// Fallback: Coba cari file langsung di folder endpoints
$fallbackFile = __DIR__ . "/endpoints/$uri.php";
if (file_exists($fallbackFile)) {
    require_once $fallbackFile;
    exit();
}

// 7. Jika tidak ada yang cocok (404)
http_response_code(200); // Kirim 200 supaya Flutter bisa baca pesan error JSON
sendResponse(false, "Endpoint '$uri' tidak terdaftar. Pastikan URL benar.");
?>
