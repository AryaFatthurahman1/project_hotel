<?php
/**
 * Users API Endpoint
 * Handles: Register, Login, Profile
 */
require_once 'config.php';
require_once 'input_validator.php';

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
    // Validate required fields
    if (empty($data['full_name']) || empty($data['email']) || empty($data['password'])) {
        response(false, 'Semua field wajib diisi!');
    }
    
    // Validate and sanitize full name
    $fullName = sanitizeString($data['full_name'], 100);
    if (empty($fullName)) {
        response(false, 'Nama lengkap tidak valid!');
    }
    
    // Validate email
    $email = validateEmail($data['email']);
    if (!$email) {
        response(false, 'Format email tidak valid!');
    }
    
    // Validate password
    $passwordValidation = validatePassword($data['password']);
    if (!$passwordValidation['valid']) {
        response(false, implode(', ', $passwordValidation['errors']));
    }
    
    // Validate phone (optional)
    $phone = '';
    if (!empty($data['phone'])) {
        $phone = validatePhone($data['phone']);
        if ($phone === false) {
            response(false, 'Format nomor telepon tidak valid!');
        }
    }
    
    // Check if email exists
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->rowCount() > 0) {
        response(false, 'Email sudah terdaftar!');
    }
    
    // Hash password securely
    $hashedPassword = password_hash($data['password'], PASSWORD_ARGON2ID, [
        'memory_cost' => 65536,
        'time_cost' => 4,
        'threads' => 3
    ]);
    
    // Insert new user
    $stmt = $conn->prepare("INSERT INTO users (full_name, email, password, phone) VALUES (?, ?, ?, ?)");
    $result = $stmt->execute([
        $fullName,
        $email,
        $hashedPassword,
        $phone
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
    // Validate required fields
    if (empty($data['email']) || empty($data['password'])) {
        response(false, 'Email dan password wajib diisi!');
    }
    
    // Validate email
    $email = validateEmail($data['email']);
    if (!$email) {
        response(false, 'Format email tidak valid!');
    }
    
    // Get user by email (don't check password in query)
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ? AND is_active = 1");
    $stmt->execute([$email]);
    
    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Verify password
        if (password_verify($data['password'], $user['password'])) {
            // Remove password from response
            unset($user['password']);
            
            // Generate JWT token
            require_once 'jwt_helper.php';
            $tokenPayload = [
                'user_id' => $user['id'],
                'email' => $user['email'],
                'full_name' => $user['full_name'],
                'role' => $user['role'] ?? 'user'
            ];
            
            $token = JWT::encode($tokenPayload);
            
            response(true, 'Login berhasil!', [
                'user' => $user,
                'token' => $token,
                'expires_in' => 3600 // 1 hour
            ]);
        } else {
            response(false, 'Email atau password salah!');
        }
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
