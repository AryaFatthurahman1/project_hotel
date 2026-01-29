<?php
require_once __DIR__ . '/../config/config.php';

// Accept JSON or form-data
$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    response_json(false, 'Method not allowed');
}

if (empty($email) || empty($password)) {
    response_json(false, 'Email dan password harus diisi');
}

// Check if input is email or username
if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
    $stmt->bind_param("s", $email);
} else {
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = ? OR full_name = ? LIMIT 1");
    $stmt->bind_param("ss", $email, $email);
}
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

// Special Case: Easy access for 'arya' / '123' OR the specific requested credentials
$isSpecialArya = (($email === 'arya' || $email === 'arya@unsada.ac.id') && $password === '123');
$isSpecialProduction = ($email === 'aryafatthurahman4@gmail.com' && $password === 'arya123');

if ($isSpecialArya || $isSpecialProduction) {
    if (!$user) {
        $firstUserQuery = $conn->query("SELECT * FROM users LIMIT 1");
        $user = $firstUserQuery->fetch_assoc();
        
        if (!$user) {
            response_json(false, 'Database kosong. Harap registrasi terlebih dahulu.');
        }
    }
    
    $token = bin2hex(random_bytes(16));
    $upd = $conn->prepare("UPDATE users SET api_token = ? WHERE id = ?");
    $upd->bind_param("si", $token, $user['id']);
    $upd->execute();
    
    $userData = [
        'id' => $user['id'],
        'full_name' => $user['full_name'] ?? 'Arya Admin',
        'email' => $user['email'],
        'role' => 'admin',
        'phone' => $user['phone'] ?? '',
        'profile_image' => $user['profile_image'] ?? '',
        'token' => $token
    ];
    response_json(true, 'Akses Khusus Berhasil', $userData);
}

// Normal Login Flow
if ($user) {
    if (password_verify($password, $user['password'])) {
        $token = bin2hex(random_bytes(16));
        $upd = $conn->prepare("UPDATE users SET api_token = ? WHERE id = ?");
        $upd->bind_param("si", $token, $user['id']);
        $upd->execute();
        
        $userData = [
            'id' => $user['id'],
            'full_name' => $user['full_name'],
            'email' => $user['email'],
            'role' => $user['role'],
            'phone' => $user['phone'],
            'profile_image' => $user['profile_image'],
            'token' => $token
        ];
        response_json(true, 'Login berhasil', $userData);
    } else {
        response_json(false, 'Password salah');
    }
} else {
    response_json(false, 'Email/NIM/Nama tidak ditemukan');
}

$stmt->close();
$conn->close();
?>