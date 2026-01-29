<?php
// Test login locally
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Simulate database connection
$users = [
    [
        'id' => 1,
        'nim' => '2023230006',
        'nama_lengkap' => 'Muhammad Arya Fatthurahman',
        'email' => 'arya@unsada.ac.id',
        'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
        'role' => 'admin',
        'phone' => '08123456789',
        'alamat' => 'Jakarta',
        'foto_profil' => null
    ],
    [
        'id' => 2,
        'nim' => '2023230006',
        'nama_lengkap' => 'Muhammad Arya Fatthurahman',
        'email' => 'arya',
        'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
        'role' => 'admin',
        'phone' => '08123456789',
        'alamat' => 'Jakarta',
        'foto_profil' => null
    ],
    [
        'id' => 999,
        'nim' => '2023230006',
        'nama_lengkap' => 'Muhammad Arya Fatthurahman',
        'email' => 'aryafatthurahman4@gmail.com',
        'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // arya123
        'role' => 'user',
        'phone' => '',
        'alamat' => 'Jakarta',
        'foto_profil' => null
    ]
];

// Accept JSON or form-data
$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => false, 'message' => 'Method not allowed']);
    exit;
}

if (empty($email) || empty($password)) {
    echo json_encode(['status' => false, 'message' => 'Email dan password harus diisi']);
    exit;
}

// Find user
$userFound = null;
foreach ($users as $user) {
    if ($user['email'] === $email || $user['nim'] === $email) {
        $userFound = $user;
        break;
    }
}

if ($userFound) {
    // Special case: allow 'arya' with password '123' or 'arya123' for easy login
    if (($email === 'arya' || $email === 'arya@unsada.ac.id' || $email === 'aryafatthurahman4@gmail.com') && ($password === '123' || $password === 'arya123')) {
        $token = bin2hex(random_bytes(16));
        
        $userData = [
            'id' => $userFound['id'],
            'nim' => $userFound['nim'],
            'nama_lengkap' => $userFound['nama_lengkap'],
            'email' => $userFound['email'],
            'role' => $userFound['role'],
            'phone' => $userFound['phone'],
            'alamat' => $userFound['alamat'],
            'foto_profil' => $userFound['foto_profil'],
            'token' => $token
        ];
        echo json_encode(['status' => true, 'message' => 'Login berhasil', 'data' => $userData]);
    }
    // Normal password verification
    elseif (password_verify($password, $userFound['password'])) {
        $token = bin2hex(random_bytes(16));
        
        $userData = [
            'id' => $userFound['id'],
            'nim' => $userFound['nim'],
            'nama_lengkap' => $userFound['nama_lengkap'],
            'email' => $userFound['email'],
            'role' => $userFound['role'],
            'phone' => $userFound['phone'],
            'alamat' => $userFound['alamat'],
            'foto_profil' => $userFound['foto_profil'],
            'token' => $token
        ];
        echo json_encode(['status' => true, 'message' => 'Login berhasil', 'data' => $userData]);
    } else {
        echo json_encode(['status' => false, 'message' => 'Password salah']);
    }
} else {
    echo json_encode(['status' => false, 'message' => 'Email/NIM tidak ditemukan']);
}
?>
