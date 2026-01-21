<?php
/**
 * API Router & Landing Page Loader
 * The Emerald Imperial - Luxury Hotel System
 * Dibuat oleh: Muhammad Arya Fatthurahman
 */

// 1. Error Reporting Configuration (Production Friendly)
error_reporting(E_ALL);
ini_set('display_errors', 0); // Hide errors from output to prevent JSON corruption

// 2. Global Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// 3. Handle Preflight Request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 4. Get and Clean URI
$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
$requestUri = str_replace('/api/', '', $requestUri);
$requestUri = trim(explode('?', $requestUri)[0], '/');

// 5. Detect if request is API or Browser
$isApiRequest = (
    strpos($_SERVER['HTTP_ACCEPT'] ?? '', 'application/json') !== false ||
    strpos($_SERVER['HTTP_USER_AGENT'] ?? '', 'Flutter') !== false ||
    $_SERVER['REQUEST_METHOD'] !== 'GET' ||
    !empty($requestUri)
);

// 6. Root Routing
if (empty($requestUri)) {
    if (!$isApiRequest) {
        // Show Elegant Landing Page
        require_once 'landing.php';
        exit();
    } else {
        header("Content-Type: application/json");
        echo json_encode([
            'status' => true,
            'message' => 'The Emerald Imperial API is Online',
            'version' => '1.2.0',
            'author' => 'Muhammad Arya Fatthurahman'
        ]);
        exit();
    }
}

// 7. Endpoint Routing
header("Content-Type: application/json");

switch ($requestUri) {
    case 'login':
    case 'login.php':
        require_once 'endpoints/login.php';
        break;
        
    case 'register':
    case 'register.php':
        require_once 'endpoints/register.php';
        break;
        
    case 'auth':
    case 'auth.php':
        require_once 'endpoints/auth.php';
        break;
        
    case 'profile':
    case 'profile.php':
        require_once 'endpoints/profile.php';
        break;
        
    case 'rooms':
    case 'rooms.php':
        require_once 'endpoints/rooms.php';
        break;
        
    case 'bookings':
    case 'bookings.php':
        require_once 'endpoints/bookings.php';
        break;
        
    case 'get_data':
    case 'get_data.php':
        require_once 'endpoints/get_data.php';
        break;
        
    case 'insert_data':
    case 'insert_data.php':
        require_once 'endpoints/insert_data.php';
        break;
        
    case 'update_data':
    case 'update_data.php':
        require_once 'endpoints/update_data.php';
        break;
        
    case 'delete_data':
    case 'delete_data.php':
        require_once 'endpoints/delete_data.php';
        break;

    case 'test':
    case 'test.php':
        require_once 'tests/test.php';
        break;
        
    default:
        http_response_code(404);
        echo json_encode([
            'status' => false,
            'message' => 'Endpoint not found: ' . $requestUri,
            'hint' => 'Check your URL or contact administrator.'
        ]);
        break;
}
?>
