<?php
/**
 * Admin Dashboard API
 * Analytics & Summary
 */
require_once __DIR__ . '/../config/config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    getDashboardStats($conn);
} else {
    response_json(false, 'Method not allowed');
}

function getDashboardStats($conn) {
    // Total Users
    $resUsers = $conn->query("SELECT COUNT(*) as count FROM users");
    $usersCount = $resUsers->fetch_assoc()['count'] ?? 0;

    // Total Hotels
    $resHotels = $conn->query("SELECT COUNT(*) as count FROM hotels");
    $hotelsCount = $resHotels->fetch_assoc()['count'] ?? 0;

    // Total Revenue (Paid Reservations)
    $resRev = $conn->query("SELECT SUM(total_price) as total FROM reservations WHERE payment_status = 'paid'");
    $revenue = $resRev->fetch_assoc()['total'] ?? 0;

    // Recent Activity (Reservations)
    $resAct = $conn->query("
        SELECT r.id, u.nama_lengkap as full_name, h.name as hotel_name, r.total_price, r.status, r.created_at 
        FROM reservations r
        JOIN users u ON r.user_id = u.id
        JOIN hotels h ON r.hotel_id = h.id
        ORDER BY r.created_at DESC
        LIMIT 5
    ");
    
    $activities = [];
    while ($row = $resAct->fetch_assoc()) {
        $activities[] = $row;
    }

    response_json(true, 'Dashboard stats loaded', [
        'total_users' => (int)$usersCount,
        'total_hotels' => (int)$hotelsCount,
        'total_revenue' => 'Rp ' . number_format($revenue, 0, ',', '.'),
        'recent_activities' => $activities
    ]);
}
?>
