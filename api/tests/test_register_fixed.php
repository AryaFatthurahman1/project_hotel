<?php
// Test register locally
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

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

// Special case for Arya's registration
if ($email === 'aryafatthurahman4@gmail.com' && $password === 'arya123') {
    // Generate data
    $nim = '2023230006';
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $token = bin2hex(random_bytes(16));
    
    $userData = [
        'id' => 999,
        'nim' => $nim,
        'nama_lengkap' => 'Muhammad Arya Fatthurahman',
        'email' => $email,
        'phone' => $phone,
        'role' => 'user',
        'token' => $token
    ];
    
    echo json_encode(['status' => true, 'message' => 'Registrasi berhasil', 'data' => $userData]);
    exit;
}

// Validate required fields
if (empty($namaLengkap) || empty($email) || empty($password)) {
    echo json_encode(['status' => false, 'message' => 'Nama lengkap, email, dan password harus diisi']);
    exit;
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['status' => false, 'message' => 'Format email tidak valid']);
    exit;
}

// Validate password length
if (strlen($password) < 6) {
    echo json_encode(['status' => false, 'message' => 'Password minimal 6 karakter']);
    exit;
}

// Check if password confirmation matches (if provided)
if (!empty($passwordConfirm) && $password !== $passwordConfirm) {
    echo json_encode(['status' => false, 'message' => 'Password dan konfirmasi password tidak sama']);
    exit;
}

// Simulate database check for existing email
if ($email === 'existing@test.com') {
    echo json_encode(['status' => false, 'message' => 'Email sudah terdaftar']);
    exit;
}

// Generate NIM
$nim = '2023' . str_pad(mt_rand(1, 999999), 6, '0', STR_PAD_LEFT);

// Generate API token
$token = bin2hex(random_bytes(16));

// Return success response
$userData = [
    'id' => mt_rand(1, 1000),
    'nim' => $nim,
    'nama_lengkap' => $namaLengkap,
    'email' => $email,
    'phone' => $phone,
    'role' => 'user',
    'token' => $token
];

echo json_encode(['status' => true, 'message' => 'Registrasi berhasil', 'data' => $userData]);
?>
