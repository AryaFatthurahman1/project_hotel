<?php
// config.php
// Dual-environment database connection (Localhost & Production)
// Dibuat oleh: Muhammad Arya Fatthurahman - 2023230006

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

date_default_timezone_set('Asia/Jakarta');

class Database {
    public $host;
    public $db_name;
    public $username;
    public $password;
    public $conn;

    public function __construct() {
        if ($_SERVER['SERVER_NAME'] === 'localhost' || $_SERVER['SERVER_ADDR'] === '127.0.0.1') {
            // Localhost Config
            $this->host = "localhost";
            $this->db_name = "hotel_arya";
            $this->username = "root";
            $this->password = "";
        } else {
            // Production Config (arya.bersama.cloud)
            $this->host = "localhost";
            $this->db_name = "bere9277_db_arya";
            $this->username = "bere9277_user_arya";
            $this->password = "aryafatturahman123";
        }
    }

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new mysqli($this->host, $this->username, $this->password, $this->db_name);
            
            if ($this->conn->connect_error) {
                // Return descriptive error for easier debugging
                response_json(false, "Koneksi Database Gagal: " . $this->conn->connect_error . " (Host: $this->host, DB: $this->db_name)");
            }
            
            $this->conn->set_charset("utf8mb4");
        } catch(Exception $e) {
            response_json(false, "Database error: " . $e->getMessage());
        }
        return $this->conn;
    }
}

function response_json($status, $message = "", $data = null) {
    header('Content-Type: application/json');
    $s = ($status === true || $status === 'success' || $status === 1) ? true : false;
    echo json_encode(["status" => $s, "message" => $message, "data" => $data]);
    exit();
}

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

    $stmt = $conn->prepare("SELECT id, nim, nama_lengkap, email, role, phone, alamat, foto_profil FROM users WHERE api_token = ? LIMIT 1");
    $stmt->bind_param("s", $token);
    $stmt->execute();
    return $stmt->get_result()->fetch_assoc();
}

$database = new Database();
$conn = $database->getConnection();
?>