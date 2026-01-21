<?php
require_once 'config.php';

$database = new Database();
$conn = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $user = validateToken($conn);
    responseJSON("success", "Data profil", $user);
}

if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    $user = validateToken($conn);
    $data = json_decode(file_get_contents("php://input"));
    
    $userId = $user['id'];
    $nama = $conn->real_escape_string($data->nama_lengkap);
    $phone = $conn->real_escape_string($data->phone);
    $alamat = $conn->real_escape_string($data->alamat);
    
    $query = "UPDATE users SET nama_lengkap = ?, phone = ?, alamat = ? WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("sssi", $nama, $phone, $alamat, $userId);
    
    if ($stmt->execute()) {
        responseJSON("success", "Profil berhasil diperbarui");
    } else {
        responseJSON("error", "Gagal memperbarui profil");
    }
}
?>
