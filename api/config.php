<?php
/**
 * Database Configuration for Grand Hotel API
 * Upload this file to cPanel File Manager
 * 
 * cPanel Access:
 * URL: https://kilimanjaro.iixcp.rumahweb.net:2083/
 * Username: bere9277
 * Password: 7gTn5pvegnZc61
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=UTF-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database credentials - Update these with your cPanel MySQL details
define('DB_HOST', 'localhost');
define('DB_NAME', 'bere9277_hotel');  // Usually: cpanel_username_dbname
define('DB_USER', 'bere9277_admin');  // Usually: cpanel_username_dbuser
define('DB_PASS', 'YourPassword123'); // Set your database password

class Database {
    private $conn;
    
    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
                DB_USER,
                DB_PASS,
                array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
            );
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Database Connection Error: ' . $e->getMessage()
            ]);
            exit();
        }
        
        return $this->conn;
    }
}

// Response helper
function response($success, $message, $data = null) {
    $response = [
        'success' => $success,
        'message' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response);
    exit();
}
?>
