<?php
/**
 * Reservations API Endpoint
 * Handles: Create, List, Detail, Cancel
 */
require_once 'config.php';

$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($method) {
    case 'GET':
        if ($action === 'detail' && isset($_GET['id'])) {
            getReservationDetail($conn, $_GET['id']);
        } elseif ($action === 'user' && isset($_GET['user_id'])) {
            getUserReservations($conn, $_GET['user_id']);
        } else {
            getAllReservations($conn);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if ($action === 'create') {
            createReservation($conn, $data);
        } elseif ($action === 'cancel') {
            cancelReservation($conn, $data);
        } elseif ($action === 'update_status') {
            updateStatus($conn, $data);
        }
        break;
        
    case 'DELETE':
        if (isset($_GET['id'])) {
            deleteReservation($conn, $_GET['id']);
        }
        break;
        
    default:
        response(false, 'Method not allowed');
}

// GET ALL RESERVATIONS
function getAllReservations($conn) {
    $stmt = $conn->query("
        SELECT r.*, u.full_name, u.email, h.name as hotel_name, h.image_url
        FROM reservations r
        JOIN users u ON r.user_id = u.id
        JOIN hotels h ON r.hotel_id = h.id
        ORDER BY r.created_at DESC
    ");
    $reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($reservations as &$res) {
        $res['total_price_formatted'] = 'Rp ' . number_format($res['total_price'], 0, ',', '.');
    }
    
    response(true, 'Reservations loaded', $reservations);
}

// GET USER RESERVATIONS
function getUserReservations($conn, $userId) {
    $stmt = $conn->prepare("
        SELECT r.*, h.name as hotel_name, h.image_url, h.address
        FROM reservations r
        JOIN hotels h ON r.hotel_id = h.id
        WHERE r.user_id = ?
        ORDER BY r.created_at DESC
    ");
    $stmt->execute([$userId]);
    $reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($reservations as &$res) {
        $res['total_price_formatted'] = 'Rp ' . number_format($res['total_price'], 0, ',', '.');
    }
    
    response(true, 'User reservations loaded', $reservations);
}

// GET RESERVATION DETAIL
function getReservationDetail($conn, $id) {
    $stmt = $conn->prepare("
        SELECT r.*, u.full_name, u.email, u.phone, h.name as hotel_name, h.image_url, h.address, h.facilities
        FROM reservations r
        JOIN users u ON r.user_id = u.id
        JOIN hotels h ON r.hotel_id = h.id
        WHERE r.id = ?
    ");
    $stmt->execute([$id]);
    
    if ($stmt->rowCount() > 0) {
        $res = $stmt->fetch(PDO::FETCH_ASSOC);
        $res['total_price_formatted'] = 'Rp ' . number_format($res['total_price'], 0, ',', '.');
        response(true, 'Reservation detail loaded', $res);
    } else {
        response(false, 'Reservation not found');
    }
}

// CREATE RESERVATION
function createReservation($conn, $data) {
    $required = ['user_id', 'hotel_id', 'check_in_date', 'check_out_date'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            response(false, "Field '$field' wajib diisi");
        }
    }
    
    // Calculate nights and total price
    $checkIn = new DateTime($data['check_in_date']);
    $checkOut = new DateTime($data['check_out_date']);
    $nights = $checkIn->diff($checkOut)->days;
    
    if ($nights < 1) {
        response(false, 'Minimal menginap 1 malam');
    }
    
    // Get hotel price
    $stmt = $conn->prepare("SELECT price_per_night FROM hotels WHERE id = ?");
    $stmt->execute([$data['hotel_id']]);
    $hotel = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$hotel) {
        response(false, 'Hotel tidak ditemukan');
    }
    
    $totalPrice = $hotel['price_per_night'] * $nights;
    
    // Insert reservation
    $stmt = $conn->prepare("
        INSERT INTO reservations (user_id, hotel_id, check_in_date, check_out_date, total_nights, total_price, guest_count, special_request)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $result = $stmt->execute([
        $data['user_id'],
        $data['hotel_id'],
        $data['check_in_date'],
        $data['check_out_date'],
        $nights,
        $totalPrice,
        $data['guest_count'] ?? 1,
        $data['special_request'] ?? null
    ]);
    
    if ($result) {
        response(true, 'Reservasi berhasil!', [
            'id' => $conn->lastInsertId(),
            'total_nights' => $nights,
            'total_price' => $totalPrice,
            'total_price_formatted' => 'Rp ' . number_format($totalPrice, 0, ',', '.')
        ]);
    } else {
        response(false, 'Gagal membuat reservasi');
    }
}

// CANCEL RESERVATION
function cancelReservation($conn, $data) {
    if (empty($data['id'])) {
        response(false, 'Reservation ID required');
    }
    
    $stmt = $conn->prepare("UPDATE reservations SET status = 'cancelled' WHERE id = ?");
    if ($stmt->execute([$data['id']])) {
        response(true, 'Reservasi dibatalkan');
    } else {
        response(false, 'Gagal membatalkan reservasi');
    }
}

// UPDATE STATUS
function updateStatus($conn, $data) {
    if (empty($data['id']) || empty($data['status'])) {
        response(false, 'ID and status required');
    }
    
    $validStatuses = ['pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled'];
    if (!in_array($data['status'], $validStatuses)) {
        response(false, 'Invalid status');
    }
    
    $stmt = $conn->prepare("UPDATE reservations SET status = ? WHERE id = ?");
    if ($stmt->execute([$data['status'], $data['id']])) {
        response(true, 'Status updated');
    } else {
        response(false, 'Update failed');
    }
}

// DELETE RESERVATION
function deleteReservation($conn, $id) {
    $stmt = $conn->prepare("DELETE FROM reservations WHERE id = ?");
    if ($stmt->execute([$id])) {
        response(true, 'Reservation deleted');
    } else {
        response(false, 'Delete failed');
    }
}
?>
