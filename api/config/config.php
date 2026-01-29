<?php
// api/config/config.php

// Setting zona waktu
date_default_timezone_set('Asia/Jakarta');

// Database configuration
class Database {
    private $host;
    private $db_name;
    private $username;
    private $password;
    public $conn;

    public function __construct() {
        if ($_SERVER['SERVER_NAME'] === 'localhost' || $_SERVER['SERVER_ADDR'] === '127.0.0.1') {
            // Localhost (Laragon/XAMPP)
            $this->host = "localhost";
            $this->db_name = "hotel_arya";
            $this->username = "root";
            $this->password = "";
        } else {
            // Production (arya.bersama.cloud - Rumahweb)
            $this->host = "localhost";
            $this->db_name = "bere9277_hotel";
            $this->username = "bere9277";
            $this->password = "7gTn5pvegnZc61";
        }
    }

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new mysqli($this->host, $this->username, $this->password, $this->db_name);
            if ($this->conn->connect_error) {
                throw new Exception("Connection failed: " . $this->conn->connect_error);
            }
            
            // Auto-check and fix schema for api_token (Suppress errors if table doesn't exist yet)
            @$check = $this->conn->query("SHOW COLUMNS FROM users LIKE 'api_token'");
            if ($check && $check->num_rows == 0) {
                @$this->conn->query("ALTER TABLE users ADD COLUMN api_token VARCHAR(255) AFTER role");
            }
            
        } catch (Exception $e) {
            http_response_code(500);
            header("Content-Type: application/json");
            echo json_encode(["status" => false, "message" => "DATABASE ERROR: " . $e->getMessage()]);
            exit();
        }
        return $this->conn;
    }
}

// Global Response Helper
function response_json($status, $message, $data = null) {
    header("Content-Type: application/json");
    echo json_encode([
        'status' => $status,
        'message' => $message,
        'data' => $data
    ]);
    exit();
}

// Token Validation Helper
function validate_token($conn) {
    $headers = getallheaders();
    $token = null;

    if (!empty($headers['Authorization']) && preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $m)) {
        $token = $m[1];
    }

    if (!$token) {
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $token = $input['token'] ?? ($_GET['token'] ?? null);
    }

    if (!$token) return null;

    $stmt = $conn->prepare("SELECT * FROM users WHERE api_token = ? LIMIT 1");
    $stmt->bind_param("s", $token);
    $stmt->execute();
    return $stmt->get_result()->fetch_assoc();
}

// Start connection
$db = new Database();
$conn = $db->getConnection();
?>