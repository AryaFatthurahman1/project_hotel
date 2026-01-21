<?php
/**
 * THE EMERALD IMPERIAL - GOLD STANDARD ROUTER
 * Dibuat oleh: Muhammad Arya Fatthurahman
 */

// 1. Error Prevention
error_reporting(E_ALL);
ini_set('display_errors', 0); // Matikan display error agar tidak merusak JSON

// 2. Security Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 3. Robust URI Detection
$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
// Clean base path if any
$basePath = '/';
if (strpos($requestUri, '/api/') === 0) { $requestUri = substr($requestUri, 4); }
$requestUri = trim(explode('?', $requestUri)[0], '/');

$isApp = (strpos($_SERVER['HTTP_USER_AGENT'] ?? '', 'Flutter') !== false || strpos($_SERVER['HTTP_ACCEPT'] ?? '', 'json') !== false);

// 4. ROUTING LOGIC
if (empty($requestUri)) {
    if (!$isApp) {
        if (file_exists('landing.php')) { require_once 'landing.php'; }
        else { echo "<h1>Emerald Imperial</h1><p>Luxury System Online</p>"; }
        exit();
    }
    $requestUri = ''; // Ensure it matches the map root
}

// Explicit Admin Route
if ($requestUri === 'admin') {
    if (file_exists('admin/index.html')) {
        readfile('admin/index.html');
        exit();
    }
}

// 5. API RESPONSE HANDLER
function sendResponse($status, $message, $data = null) {
    header("Content-Type: application/json");
    echo json_encode([
        'status' => $status,
        'message' => $message,
        'data' => $data,
        'timestamp' => time()
    ]);
    exit();
}

// 6. ENDPOINT MAPPING
$endpointMap = [
    '' => 'root',
    'login' => 'endpoints/login.php',
    'register' => 'endpoints/register.php',
    'auth' => 'endpoints/auth.php',
    'profile' => 'endpoints/profile.php',
    'rooms' => 'endpoints/rooms.php',
    'bookings' => 'endpoints/bookings.php',
    'get_data' => 'endpoints/get_data.php',
    'insert_data' => 'endpoints/insert_data.php',
    'update_data' => 'endpoints/update_data.php',
    'delete_data' => 'endpoints/delete_data.php'
];

$file = $endpointMap[$requestUri] ?? null;

if ($file === 'root') {
    sendResponse(true, "The Emerald Imperial API is fully operational.");
}

if ($file && file_exists($file)) {
    require_once $file;
    exit();
}

// 7. Fallback for .php extension
if (file_exists("endpoints/$requestUri.php")) {
    require_once "endpoints/$requestUri.php";
    exit();
}

// 404
http_response_code(200); // Ganti dari 404 ke 200 agar Flutter tidak crash, tapi status false
sendResponse(false, "Endpoint '$requestUri' tidak ditemukan. Pastikan URL benar.");
?>
