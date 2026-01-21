<?php
require_once 'config.php';

$database = new Database();
$conn = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $query = "SELECT * FROM rooms WHERE is_available = 1 ORDER BY room_number";
    $result = $conn->query($query);
    
    $rooms = [];
    while ($row = $result->fetch_assoc()) {
        $rooms[] = $row;
    }
    
    responseJSON("success", "Data kamar berhasil diambil", $rooms);
}
?>
