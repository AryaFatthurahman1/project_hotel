<?php
/**
 * Food Menu API Endpoint
 * Handles: List, Detail, Categories
 */
require_once 'config.php';

$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($method) {
    case 'GET':
        if ($action === 'detail' && isset($_GET['id'])) {
            getFoodDetail($conn, $_GET['id']);
        } elseif ($action === 'category' && isset($_GET['category'])) {
            getByCategory($conn, $_GET['category']);
        } elseif ($action === 'featured') {
            getFeatured($conn);
        } else {
            getAllFood($conn);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if ($action === 'create') {
            createFood($conn, $data);
        } elseif ($action === 'update') {
            updateFood($conn, $data);
        }
        break;
        
    case 'DELETE':
        if (isset($_GET['id'])) {
            deleteFood($conn, $_GET['id']);
        }
        break;
        
    default:
        response(false, 'Method not allowed');
}

// GET ALL FOOD
function getAllFood($conn) {
    $stmt = $conn->query("SELECT * FROM food_menu WHERE is_available = 1 ORDER BY category, name");
    $foods = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($foods as &$food) {
        $food['price_formatted'] = 'Rp ' . number_format($food['price'], 0, ',', '.');
    }
    
    response(true, 'Menu loaded', $foods);
}

// GET FOOD DETAIL
function getFoodDetail($conn, $id) {
    $stmt = $conn->prepare("SELECT * FROM food_menu WHERE id = ?");
    $stmt->execute([$id]);
    
    if ($stmt->rowCount() > 0) {
        $food = $stmt->fetch(PDO::FETCH_ASSOC);
        $food['price_formatted'] = 'Rp ' . number_format($food['price'], 0, ',', '.');
        response(true, 'Food detail loaded', $food);
    } else {
        response(false, 'Food not found');
    }
}

// GET BY CATEGORY
function getByCategory($conn, $category) {
    $stmt = $conn->prepare("SELECT * FROM food_menu WHERE category = ? AND is_available = 1 ORDER BY name");
    $stmt->execute([$category]);
    $foods = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($foods as &$food) {
        $food['price_formatted'] = 'Rp ' . number_format($food['price'], 0, ',', '.');
    }
    
    response(true, 'Foods by category', $foods);
}

// GET FEATURED
function getFeatured($conn) {
    $stmt = $conn->query("SELECT * FROM food_menu WHERE is_featured = 1 AND is_available = 1 ORDER BY name");
    $foods = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($foods as &$food) {
        $food['price_formatted'] = 'Rp ' . number_format($food['price'], 0, ',', '.');
    }
    
    response(true, 'Featured foods', $foods);
}

// CREATE FOOD
function createFood($conn, $data) {
    if (empty($data['name']) || empty($data['price'])) {
        response(false, 'Name dan price wajib diisi');
    }
    
    $stmt = $conn->prepare("
        INSERT INTO food_menu (name, description, price, category, image_url, is_featured)
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    
    $result = $stmt->execute([
        $data['name'],
        $data['description'] ?? '',
        $data['price'],
        $data['category'] ?? 'main_course',
        $data['image_url'] ?? null,
        $data['is_featured'] ?? 0
    ]);
    
    if ($result) {
        response(true, 'Food item created', ['id' => $conn->lastInsertId()]);
    } else {
        response(false, 'Failed to create food item');
    }
}

// UPDATE FOOD
function updateFood($conn, $data) {
    if (empty($data['id'])) {
        response(false, 'Food ID required');
    }
    
    $stmt = $conn->prepare("
        UPDATE food_menu SET
            name = COALESCE(?, name),
            description = COALESCE(?, description),
            price = COALESCE(?, price),
            is_available = COALESCE(?, is_available),
            is_featured = COALESCE(?, is_featured)
        WHERE id = ?
    ");
    
    $result = $stmt->execute([
        $data['name'] ?? null,
        $data['description'] ?? null,
        $data['price'] ?? null,
        $data['is_available'] ?? null,
        $data['is_featured'] ?? null,
        $data['id']
    ]);
    
    if ($result) {
        response(true, 'Food item updated');
    } else {
        response(false, 'Update failed');
    }
}

// DELETE FOOD
function deleteFood($conn, $id) {
    $stmt = $conn->prepare("DELETE FROM food_menu WHERE id = ?");
    if ($stmt->execute([$id])) {
        response(true, 'Food item deleted');
    } else {
        response(false, 'Delete failed');
    }
}
?>
