<?php
// config.php
// Koneksi Database untuk Luxury Hotel System
// Dibuat oleh: Muhammad Arya Fatthurahman - 2023230006

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

date_default_timezone_set('Asia/Jakarta');

class Database {
    public $host = "localhost";
    public $db_name = "hotel_arya";
    public $username = "root";
    public $password = "";
    public $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new mysqli($this->host, $this->username, $this->password, $this->db_name);
            
            if ($this->conn->connect_error) {
                throw new Exception("Connection failed: " . $this->conn->connect_error);
            }
            
            $this->conn->set_charset("utf8");
        } catch(Exception $e) {
            echo json_encode([
                "status" => "error",
                "message" => "Database connection error: " . $e->getMessage()
            ]);
            exit();
        }
        return $this->conn;
    }
}

// Create both mysqli and PDO connections so API files using either style work
$database = new Database();
$conn = $database->getConnection();

// also create PDO instance
// handle OPTIONS preflight early (helpful when API is called from browser)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $pdo_dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $database->host ?? 'localhost', $database->db_name ?? 'project_hotel');
    $pdo = new PDO($pdo_dsn, $database->username ?? 'root', $database->password ?? '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (Exception $e) {
    // ignore here; some scripts may only use mysqli
    $pdo = null;
}

function responseJSON($status, $message = "", $data = []) {
    $response = [
        "status" => $status,
        "message" => $message,
        "data" => $data
    ];
    echo json_encode($response);
    exit();
}

// alias kebalikan gaya penamaan yang dipakai beberapa file
function response_json($status, $message = "", $data = null) {
    // keep boolean-like for older callers
    $s = ($status === true || $status === 'success' || $status === 'ok' || $status === 1) ? true : ($status === false || $status === 'error' ? false : $status);
    echo json_encode(["status" => $s, "message" => $message, "data" => $data]);
    exit();
}

function validateToken($conn) {
    $headers = apache_request_headers();
    if (!isset($headers['Authorization'])) {
        responseJSON("error", "Token tidak ditemukan");
    }
    
    $token = str_replace("Bearer ", "", $headers['Authorization']);
    $query = "SELECT * FROM users WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $token);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        responseJSON("error", "Token tidak valid");
    }
    
    return $result->fetch_assoc();
}
?>