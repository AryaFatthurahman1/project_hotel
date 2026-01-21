<?php
// API Router for Luxury Hotel System
// This file routes all API requests to appropriate endpoints

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get the requested endpoint
$requestUri = $_SERVER['REQUEST_URI'];
$requestUri = str_replace('/api/', '', $requestUri);
$requestUri = explode('?', $requestUri)[0]; // Remove query parameters

// Route to appropriate endpoint
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
        
    // Test endpoints
    case 'test_login':
    case 'test_login.php':
        require_once 'tests/test_login.php';
        break;
        
    case 'test_register':
    case 'test_register.php':
        require_once 'tests/test_register_fixed.php';
        break;
        
    default:
        // Return 404 for unknown endpoints
        http_response_code(404);
        echo json_encode([
            'status' => false,
            'message' => 'Endpoint not found: ' . $requestUri,
            'available_endpoints' => [
                'login',
                'register',
                'auth',
                'profile',
                'rooms',
                'bookings',
                'get_data',
                'insert_data',
                'update_data',
                'delete_data',
                'test_login',
                'test_register'
            ]
        ]);
        break;
}
?>
