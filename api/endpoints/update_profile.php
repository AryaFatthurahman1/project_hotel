<?php
require_once '../config/config.php';

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$userId = $input['user_id'] ?? '';
$name = $input['name'] ?? '';
$email = $input['email'] ?? '';
$notes = $input['notes'] ?? '';
$plannedDate = $input['planned_date'] ?? '';

if (empty($userId)) {
    response_json(false, 'User ID ID required');
}

$stmt = $conn->prepare("UPDATE users SET nama_lengkap = ?, email = ?, alamat = ? WHERE id = ?");
// Using 'alamat' field for notes for now or we could add a new column if needed
// But let's just simulate the success for now as a POC
$stmt->bind_param("sssi", $name, $email, $notes, $userId);

if ($stmt->execute()) {
    response_json(true, 'Profil berhasil diperbarui');
} else {
    response_json(false, 'Gagal memperbarui profil');
}

$stmt->close();
$conn->close();
?>
