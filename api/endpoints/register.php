<?php
require_once __DIR__ . '/../config/config.php';

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Accept JSON or form-data
$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$namaLengkap = trim($input['nama_lengkap'] ?? '');
$email = trim($input['email'] ?? '');
$phone = trim($input['phone'] ?? '');
$password = $input['password'] ?? '';
$passwordConfirm = $input['password_confirmation'] ?? '';

// Validate required fields
if (empty($namaLengkap) || empty($email) || empty($password)) {
    response_json(false, 'Nama lengkap, email, dan password harus diisi');
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    response_json(false, 'Format email tidak valid');
}

// Validate password length
if (strlen($password) < 6) {
    response_json(false, 'Password minimal 6 karakter');
}

// Check if password confirmation matches (if provided)
if (!empty($passwordConfirm) && $password !== $passwordConfirm) {
    response_json(false, 'Password dan konfirmasi password tidak sama');
}

// Check existing email
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    response_json(false, 'Email sudah terdaftar');
}

// Generate NIM if not provided
$nim = '2023' . str_pad(mt_rand(1, 999999), 6, '0', STR_PAD_LEFT);

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Generate API token
$token = bin2hex(random_bytes(16));

// Insert user with correct field names
$insert = $conn->prepare("INSERT INTO users (nim, nama_lengkap, email, password, phone, role, api_token) VALUES (?, ?, ?, ?, ?, 'user', ?)");
$insert->bind_param("ssssss", $nim, $namaLengkap, $email, $hashedPassword, $phone, $token);

if ($insert->execute()) {
    $userId = $conn->insert_id;
    
    // Return user data
    $userData = [
        'id' => $userId,
        'nim' => $nim,
        'nama_lengkap' => $namaLengkap,
        'email' => $email,
        'phone' => $phone,
        'role' => 'user',
        'token' => $token
    ];
    
    response_json(true, 'Registrasi berhasil', $userData);
} else {
    response_json(false, 'Registrasi gagal: ' . $conn->error);
}

$insert->close();
$stmt->close();
$conn->close();
?>
