<?php
/**
 * Hotels API Endpoint
 * Handles: List, Detail, Search, CRUD
 */
require_once 'config.php';

$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($method) {
    case 'GET':
        if ($action === 'detail' && isset($_GET['id'])) {
            getHotelDetail($conn, $_GET['id']);
        } elseif ($action === 'search') {
            searchHotels($conn, $_GET);
        } else {
            getAllHotels($conn);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if ($action === 'create') {
            createHotel($conn, $data);
        } elseif ($action === 'update') {
            updateHotel($conn, $data);
        }
        break;
        
    case 'DELETE':
        if (isset($_GET['id'])) {
            deleteHotel($conn, $_GET['id']);
        }
        break;
        
    default:
        response(false, 'Method not allowed');
}

// GET ALL HOTELS
function getAllHotels($conn) {
    $stmt = $conn->query("SELECT * FROM hotels WHERE is_available = 1 ORDER BY rating DESC");
    $hotels = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format price
    foreach ($hotels as &$hotel) {
        $hotel['price_formatted'] = 'Rp ' . number_format($hotel['price_per_night'], 0, ',', '.');
        $hotel['facilities_list'] = explode(', ', $hotel['facilities']);
    }
    
    response(true, 'Hotels loaded', $hotels);
}

// GET HOTEL DETAIL
function getHotelDetail($conn, $id) {
    $stmt = $conn->prepare("SELECT * FROM hotels WHERE id = ?");
    $stmt->execute([$id]);
    
    if ($stmt->rowCount() > 0) {
        $hotel = $stmt->fetch(PDO::FETCH_ASSOC);
        $hotel['price_formatted'] = 'Rp ' . number_format($hotel['price_per_night'], 0, ',', '.');
        $hotel['facilities_list'] = explode(', ', $hotel['facilities']);
        response(true, 'Hotel detail loaded', $hotel);
    } else {
        response(false, 'Hotel not found');
    }
}

// SEARCH HOTELS
function searchHotels($conn, $params) {
    $where = ["is_available = 1"];
    $values = [];
    
    if (!empty($params['city'])) {
        $where[] = "city LIKE ?";
        $values[] = '%' . $params['city'] . '%';
    }
    
    if (!empty($params['room_type'])) {
        $where[] = "room_type = ?";
        $values[] = $params['room_type'];
    }
    
    if (!empty($params['min_price'])) {
        $where[] = "price_per_night >= ?";
        $values[] = $params['min_price'];
    }
    
    if (!empty($params['max_price'])) {
        $where[] = "price_per_night <= ?";
        $values[] = $params['max_price'];
    }
    
    if (!empty($params['keyword'])) {
        $where[] = "(name LIKE ? OR description LIKE ?)";
        $values[] = '%' . $params['keyword'] . '%';
        $values[] = '%' . $params['keyword'] . '%';
    }
    
    $sql = "SELECT * FROM hotels WHERE " . implode(' AND ', $where) . " ORDER BY rating DESC";
    $stmt = $conn->prepare($sql);
    $stmt->execute($values);
    
    $hotels = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($hotels as &$hotel) {
        $hotel['price_formatted'] = 'Rp ' . number_format($hotel['price_per_night'], 0, ',', '.');
    }
    
    response(true, 'Search results', $hotels);
}

// CREATE HOTEL
function createHotel($conn, $data) {
    $required = ['name', 'price_per_night'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            response(false, "Field '$field' wajib diisi");
        }
    }
    
    $stmt = $conn->prepare("
        INSERT INTO hotels (name, description, address, city, price_per_night, rating, image_url, facilities, room_type, total_rooms)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $result = $stmt->execute([
        $data['name'],
        $data['description'] ?? '',
        $data['address'] ?? '',
        $data['city'] ?? 'Jakarta',
        $data['price_per_night'],
        $data['rating'] ?? 0,
        $data['image_url'] ?? '',
        $data['facilities'] ?? '',
        $data['room_type'] ?? 'standard',
        $data['total_rooms'] ?? 10
    ]);
    
    if ($result) {
        response(true, 'Hotel berhasil ditambahkan', ['id' => $conn->lastInsertId()]);
    } else {
        response(false, 'Gagal menambahkan hotel');
    }
}

// UPDATE HOTEL
function updateHotel($conn, $data) {
    if (empty($data['id'])) {
        response(false, 'Hotel ID required');
    }
    
    $stmt = $conn->prepare("
        UPDATE hotels SET
            name = COALESCE(?, name),
            description = COALESCE(?, description),
            price_per_night = COALESCE(?, price_per_night),
            rating = COALESCE(?, rating),
            is_available = COALESCE(?, is_available)
        WHERE id = ?
    ");
    
    $result = $stmt->execute([
        $data['name'] ?? null,
        $data['description'] ?? null,
        $data['price_per_night'] ?? null,
        $data['rating'] ?? null,
        $data['is_available'] ?? null,
        $data['id']
    ]);
    
    if ($result) {
        response(true, 'Hotel updated');
    } else {
        response(false, 'Update failed');
    }
}

// DELETE HOTEL
function deleteHotel($conn, $id) {
    $stmt = $conn->prepare("DELETE FROM hotels WHERE id = ?");
    if ($stmt->execute([$id])) {
        response(true, 'Hotel deleted');
    } else {
        response(false, 'Delete failed');
    }
}
?>
