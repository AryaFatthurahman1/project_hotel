<?php
/**
 * Admin Dashboard API
 * Analytics & Summary
 */
require_once 'config.php';

$db = new Database();
$conn = $db->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    getDashboardStats($conn);
} else {
    response(false, 'Method not allowed');
}

function getDashboardStats($conn) {
    // Total Users
    $stmt = $conn->query("SELECT COUNT(*) as count FROM users");
    $users = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

    // Total Hotels
    $stmt = $conn->query("SELECT COUNT(*) as count FROM hotels");
    $hotels = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

    // Total Revenue (Paid Reservations)
    $stmt = $conn->query("SELECT SUM(total_price) as total FROM reservations WHERE payment_status = 'paid'");
    $revenue = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;

    // Recent Activity (Reservations)
    $stmt = $conn->query("
        SELECT r.id, u.full_name, h.name as hotel_name, r.total_price, r.status, r.created_at 
        FROM reservations r
        JOIN users u ON r.user_id = u.id
        JOIN hotels h ON r.hotel_id = h.id
        ORDER BY r.created_at DESC
        LIMIT 5
    ");
    $activities = $stmt->fetchAll(PDO::FETCH_ASSOC);

    response(true, 'Dashboard stats loaded', [
        'total_users' => $users,
        'total_hotels' => $hotels,
        'total_revenue' => 'Rp ' . number_format($revenue, 0, ',', '.'),
        'recent_activities' => $activities
    ]);
}
?>
