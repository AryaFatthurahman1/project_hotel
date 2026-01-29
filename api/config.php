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

// Load environment variables
function loadEnv($file) {
    if (!file_exists($file)) {
        return;
    }
    
    $lines = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) {
            continue;
        }
        
        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value);
        
        if (!array_key_exists($name, $_SERVER) && !array_key_exists($name, $_ENV)) {
            putenv(sprintf('%s=%s', $name, $value));
            $_ENV[$name] = $value;
            $_SERVER[$name] = $value;
        }
    }
}

// Load environment variables from .env file
loadEnv(__DIR__ . '/.env');

// Database credentials - Use environment variables or fallback defaults
define('DB_HOST', $_ENV['DB_HOST'] ?? 'localhost');
define('DB_NAME', $_ENV['DB_NAME'] ?? 'bere9277_hotel');
define('DB_USER', $_ENV['DB_USER'] ?? 'bere9277_admin');
define('DB_PASS', $_ENV['DB_PASS'] ?? 'YourPassword123');

// JWT Configuration
define('JWT_SECRET_KEY', $_ENV['JWT_SECRET_KEY'] ?? 'GrandHotel_SecretKey_2026_Kilimanjaro_Hosting_Secure_JWT_Token');
define('JWT_EXPIRATION', $_ENV['JWT_EXPIRATION'] ?? 3600);

// Application Configuration
define('APP_ENV', $_ENV['APP_ENV'] ?? 'production');
define('APP_DEBUG', $_ENV['APP_DEBUG'] ?? 'false');
define('APP_URL', $_ENV['APP_URL'] ?? 'https://kilimanjaro.iixcp.rumahweb.net');

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
