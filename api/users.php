<?php
/**
 * Users API Endpoint
 * Handles: Register, Login, Profile
 */
require_once 'config.php';

$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($method) {
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if ($action === 'register') {
            registerUser($conn, $data);
        } elseif ($action === 'login') {
            loginUser($conn, $data);
        } elseif ($action === 'update') {
            updateUser($conn, $data);
        }
        break;
        
    case 'GET':
        if ($action === 'profile' && isset($_GET['id'])) {
            getProfile($conn, $_GET['id']);
        } elseif ($action === 'all') {
            getAllUsers($conn);
        }
        break;
        
    case 'DELETE':
        if (isset($_GET['id'])) {
            deleteUser($conn, $_GET['id']);
        }
        break;
        
    default:
        response(false, 'Method not allowed');
}

// REGISTER
function registerUser($conn, $data) {
    if (empty($data['full_name']) || empty($data['email']) || empty($data['password'])) {
        response(false, 'Semua field wajib diisi!');
    }
    
    // Check if email exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$data['email']]);
    if ($stmt->rowCount() > 0) {
        response(false, 'Email sudah terdaftar!');
    }
    
    // Insert new user
    $stmt = $conn->prepare("INSERT INTO users (full_name, email, password, phone) VALUES (?, ?, ?, ?)");
    $result = $stmt->execute([
        $data['full_name'],
        $data['email'],
        $data['password'], // In production, use password_hash()
        $data['phone'] ?? null
    ]);
    
    if ($result) {
        $userId = $conn->lastInsertId();
        response(true, 'Registrasi berhasil!', ['id' => $userId]);
    } else {
        response(false, 'Registrasi gagal!');
    }
}

// LOGIN
function loginUser($conn, $data) {
    if (empty($data['email']) || empty($data['password'])) {
        response(false, 'Email dan password wajib diisi!');
    }
    
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ? AND password = ? AND is_active = 1");
    $stmt->execute([$data['email'], $data['password']]);
    
    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        unset($user['password']); // Remove password from response
        response(true, 'Login berhasil!', $user);
    } else {
        response(false, 'Email atau password salah!');
    }
}

// GET PROFILE
function getProfile($conn, $id) {
    $stmt = $conn->prepare("SELECT id, full_name, email, phone, profile_image, role, created_at FROM users WHERE id = ?");
    $stmt->execute([$id]);
    
    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        response(true, 'Profile loaded', $user);
    } else {
        response(false, 'User not found');
    }
}

// GET ALL USERS (Admin)
function getAllUsers($conn) {
    $stmt = $conn->query("SELECT id, full_name, email, phone, role, is_active, created_at FROM users ORDER BY created_at DESC");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    response(true, 'Users loaded', $users);
}

// UPDATE USER
function updateUser($conn, $data) {
    if (empty($data['id'])) {
        response(false, 'User ID required');
    }
    
    $updates = [];
    $params = [];
    
    if (!empty($data['full_name'])) {
        $updates[] = "full_name = ?";
        $params[] = $data['full_name'];
    }
    if (!empty($data['phone'])) {
        $updates[] = "phone = ?";
        $params[] = $data['phone'];
    }
    if (!empty($data['profile_image'])) {
        $updates[] = "profile_image = ?";
        $params[] = $data['profile_image'];
    }
    
    if (empty($updates)) {
        response(false, 'No data to update');
    }
    
    $params[] = $data['id'];
    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    
    if ($stmt->execute($params)) {
        response(true, 'Profile updated successfully');
    } else {
        response(false, 'Update failed');
    }
}

// DELETE USER
function deleteUser($conn, $id) {
    $stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
    if ($stmt->execute([$id])) {
        response(true, 'User deleted');
    } else {
        response(false, 'Delete failed');
    }
}
?>
