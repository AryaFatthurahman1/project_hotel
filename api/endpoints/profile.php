<?php
// api/endpoints/profile.php
require_once __DIR__ . '/../config/config.php';

$user = validate_token($conn);

if (!$user) {
    response_json(false, "Sesi tidak valid atau telah berakhir. Silakan login kembali.");
}

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    response_json(true, "Data profil berhasil diambil", $user);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST' || $_SERVER['REQUEST_METHOD'] == 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    
    $userId = $user['id'];
    $nama = trim($input['nama_lengkap'] ?? $user['nama_lengkap']);
    $phone = trim($input['phone'] ?? $user['phone']);
    $alamat = trim($input['alamat'] ?? $user['alamat']);
    
    $stmt = $conn->prepare("UPDATE users SET nama_lengkap = ?, phone = ?, alamat = ? WHERE id = ?");
    $stmt->bind_param("sssi", $nama, $phone, $alamat, $userId);
    
    if ($stmt->execute()) {
        $updatedUser = validate_token($conn); // reload data
        response_json(true, "Profil berhasil diperbarui", $updatedUser);
    } else {
        response_json(false, "Gagal memperbarui profil: " . $conn->error);
    }
}
?>
