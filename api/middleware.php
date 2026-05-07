<?php
/**
 * Authentication Middleware for JWT Token Validation
 * Use this to protect API endpoints that require authentication
 */
require_once 'jwt_helper.php';

/**
 * Validate JWT token from Authorization header
 * @return array|false Returns user data if valid, false if invalid
 */
function validateJWTToken() {
    // Get Authorization header
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : 
                  (isset($headers['authorization']) ? $headers['authorization'] : null);
    
    if (!$authHeader) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Authorization header required',
            'error_code' => 'MISSING_AUTH_HEADER'
        ]);
        exit();
    }
    
    // Extract token from "Bearer <token>" format
    if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid authorization format. Use: Bearer <token>',
            'error_code' => 'INVALID_AUTH_FORMAT'
        ]);
        exit();
    }
    
    $token = $matches[1];
    
    // Validate token
    $validation = JWT::validateToken($token);
    
    if (!$validation['valid']) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid or expired token',
            'error_code' => 'INVALID_TOKEN',
            'details' => $validation['error']
        ]);
        exit();
    }
    
    return $validation['payload'];
}

/**
 * Check if user has admin role
 * @param array $userPayload User data from JWT token
 */
function requireAdmin($userPayload) {
    if (!isset($userPayload['role']) || $userPayload['role'] !== 'admin') {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Admin access required',
            'error_code' => 'INSUFFICIENT_PERMISSIONS'
        ]);
        exit();
    }
}

/**
 * Get current authenticated user
 * @return array User data from JWT token
 */
function getCurrentUser() {
    return validateJWTToken();
}

/**
 * Optional token validation - doesn't exit if invalid
 * @return array|null User data if valid, null if invalid
 */
function optionalJWTToken() {
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : 
                  (isset($headers['authorization']) ? $headers['authorization'] : null);
    
    if (!$authHeader) {
        return null;
    }
    
    if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        return null;
    }
    
    $token = $matches[1];
    $validation = JWT::validateToken($token);
    
    return $validation['valid'] ? $validation['payload'] : null;
}

/**
 * Refresh JWT token
 * @return string New JWT token
 */
function refreshToken() {
    $headers = getallheaders();
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : 
                  (isset($headers['authorization']) ? $headers['authorization'] : null);
    
    if (!$authHeader) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Authorization header required',
            'error_code' => 'MISSING_AUTH_HEADER'
        ]);
        exit();
    }
    
    if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid authorization format',
            'error_code' => 'INVALID_AUTH_FORMAT'
        ]);
        exit();
    }
    
    try {
        $newToken = JWT::refreshToken($matches[1]);
        return $newToken;
    } catch (Exception $e) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Token refresh failed',
            'error_code' => 'REFRESH_FAILED',
            'details' => $e->getMessage()
        ]);
        exit();
    }
}
?>
