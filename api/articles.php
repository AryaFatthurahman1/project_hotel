<?php
/**
 * Articles API Endpoint
 * Handles: List, Detail, Create, Update, Delete
 */
require_once 'config.php';

$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($method) {
    case 'GET':
        if ($action === 'detail' && isset($_GET['id'])) {
            getArticleDetail($conn, $_GET['id']);
        } elseif ($action === 'category' && isset($_GET['category'])) {
            getByCategory($conn, $_GET['category']);
        } else {
            getAllArticles($conn);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if ($action === 'create') {
            createArticle($conn, $data);
        } elseif ($action === 'update') {
            updateArticle($conn, $data);
        }
        break;
        
    case 'DELETE':
        if (isset($_GET['id'])) {
            deleteArticle($conn, $_GET['id']);
        }
        break;
        
    default:
        response(false, 'Method not allowed');
}

// GET ALL ARTICLES
function getAllArticles($conn) {
    $stmt = $conn->query("SELECT * FROM articles WHERE is_published = 1 ORDER BY created_at DESC");
    $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($articles as &$article) {
        $article['created_at_formatted'] = date('d M Y', strtotime($article['created_at']));
    }
    
    response(true, 'Articles loaded', $articles);
}

// GET ARTICLE DETAIL
function getArticleDetail($conn, $id) {
    // Increment views
    $conn->exec("UPDATE articles SET views = views + 1 WHERE id = $id");
    
    $stmt = $conn->prepare("SELECT * FROM articles WHERE id = ?");
    $stmt->execute([$id]);
    
    if ($stmt->rowCount() > 0) {
        $article = $stmt->fetch(PDO::FETCH_ASSOC);
        $article['created_at_formatted'] = date('d M Y', strtotime($article['created_at']));
        response(true, 'Article loaded', $article);
    } else {
        response(false, 'Article not found');
    }
}

// GET BY CATEGORY
function getByCategory($conn, $category) {
    $stmt = $conn->prepare("SELECT * FROM articles WHERE category = ? AND is_published = 1 ORDER BY created_at DESC");
    $stmt->execute([$category]);
    $articles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($articles as &$article) {
        $article['created_at_formatted'] = date('d M Y', strtotime($article['created_at']));
    }
    
    response(true, 'Articles by category', $articles);
}

// CREATE ARTICLE
function createArticle($conn, $data) {
    if (empty($data['title']) || empty($data['content'])) {
        response(false, 'Title dan content wajib diisi');
    }
    
    $stmt = $conn->prepare("
        INSERT INTO articles (title, content, excerpt, image_url, author, category)
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    
    $result = $stmt->execute([
        $data['title'],
        $data['content'],
        $data['excerpt'] ?? substr($data['content'], 0, 200),
        $data['image_url'] ?? null,
        $data['author'] ?? 'Admin',
        $data['category'] ?? 'news'
    ]);
    
    if ($result) {
        response(true, 'Article created', ['id' => $conn->lastInsertId()]);
    } else {
        response(false, 'Failed to create article');
    }
}

// UPDATE ARTICLE
function updateArticle($conn, $data) {
    if (empty($data['id'])) {
        response(false, 'Article ID required');
    }
    
    $updates = [];
    $params = [];
    
    if (!empty($data['title'])) {
        $updates[] = "title = ?";
        $params[] = $data['title'];
    }
    if (!empty($data['content'])) {
        $updates[] = "content = ?";
        $params[] = $data['content'];
    }
    if (!empty($data['excerpt'])) {
        $updates[] = "excerpt = ?";
        $params[] = $data['excerpt'];
    }
    if (!empty($data['image_url'])) {
        $updates[] = "image_url = ?";
        $params[] = $data['image_url'];
    }
    if (isset($data['is_published'])) {
        $updates[] = "is_published = ?";
        $params[] = $data['is_published'];
    }
    
    if (empty($updates)) {
        response(false, 'No data to update');
    }
    
    $params[] = $data['id'];
    $sql = "UPDATE articles SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    
    if ($stmt->execute($params)) {
        response(true, 'Article updated');
    } else {
        response(false, 'Update failed');
    }
}

// DELETE ARTICLE
function deleteArticle($conn, $id) {
    $stmt = $conn->prepare("DELETE FROM articles WHERE id = ?");
    if ($stmt->execute([$id])) {
        response(true, 'Article deleted');
    } else {
        response(false, 'Delete failed');
    }
}
?>
