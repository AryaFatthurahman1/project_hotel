<?php
/**
 * Input Validation and Sanitization Helper
 * Prevents XSS attacks and ensures data integrity
 */

/**
 * Sanitize string input
 * @param string $input Raw input
 * @param int $maxLength Maximum allowed length
 * @return string Sanitized output
 */
function sanitizeString($input, $maxLength = 255) {
    if (empty($input)) {
        return '';
    }
    
    // Remove HTML tags and special characters
    $cleaned = strip_tags($input);
    $cleaned = htmlspecialchars($cleaned, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    
    // Trim whitespace
    $cleaned = trim($cleaned);
    
    // Limit length
    if (strlen($cleaned) > $maxLength) {
        $cleaned = substr($cleaned, 0, $maxLength);
    }
    
    return $cleaned;
}

/**
 * Validate and sanitize email
 * @param string $email Email address
 * @return string|false Sanitized email or false if invalid
 */
function validateEmail($email) {
    if (empty($email)) {
        return false;
    }
    
    $email = filter_var($email, FILTER_SANITIZE_EMAIL);
    
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return false;
    }
    
    // Limit email length
    if (strlen($email) > 254) {
        return false;
    }
    
    return strtolower($email);
}

/**
 * Validate password strength
 * @param string $password Password to validate
 * @return array Validation result
 */
function validatePassword($password) {
    $result = [
        'valid' => true,
        'errors' => []
    ];
    
    if (empty($password)) {
        $result['valid'] = false;
        $result['errors'][] = 'Password is required';
        return $result;
    }
    
    if (strlen($password) < 8) {
        $result['valid'] = false;
        $result['errors'][] = 'Password must be at least 8 characters long';
    }
    
    if (strlen($password) > 128) {
        $result['valid'] = false;
        $result['errors'][] = 'Password must be less than 128 characters';
    }
    
    // Check for at least one uppercase letter
    if (!preg_match('/[A-Z]/', $password)) {
        $result['valid'] = false;
        $result['errors'][] = 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!preg_match('/[a-z]/', $password)) {
        $result['valid'] = false;
        $result['errors'][] = 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!preg_match('/[0-9]/', $password)) {
        $result['valid'] = false;
        $result['errors'][] = 'Password must contain at least one number';
    }
    
    return $result;
}

/**
 * Validate phone number
 * @param string $phone Phone number
 * @return string|false Sanitized phone or false if invalid
 */
function validatePhone($phone) {
    if (empty($phone)) {
        return '';
    }
    
    // Remove all non-numeric characters
    $phone = preg_replace('/[^0-9]/', '', $phone);
    
    // Check if it's a reasonable length (10-15 digits)
    if (strlen($phone) < 10 || strlen($phone) > 15) {
        return false;
    }
    
    return $phone;
}

/**
 * Validate numeric input
 * @param mixed $input Input to validate
 * @param float $min Minimum value
 * @param float $max Maximum value
 * @return float|false Validated number or false if invalid
 */
function validateNumber($input, $min = null, $max = null) {
    if (!is_numeric($input)) {
        return false;
    }
    
    $number = (float) $input;
    
    if ($min !== null && $number < $min) {
        return false;
    }
    
    if ($max !== null && $number > $max) {
        return false;
    }
    
    return $number;
}

/**
 * Validate date input
 * @param string $date Date string
 * @param string $format Expected date format (default: Y-m-d)
 * @return string|false Validated date or false if invalid
 */
function validateDate($date, $format = 'Y-m-d') {
    if (empty($date)) {
        return false;
    }
    
    $dateObj = DateTime::createFromFormat($format, $date);
    
    if (!$dateObj || $dateObj->format($format) !== $date) {
        return false;
    }
    
    return $date;
}

/**
 * Validate file upload
 * @param array $file $_FILES array element
 * @param array $allowedTypes Allowed MIME types
 * @param int $maxSize Maximum file size in bytes
 * @return array Validation result
 */
function validateFileUpload($file, $allowedTypes = [], $maxSize = 5242880) { // 5MB default
    $result = [
        'valid' => true,
        'errors' => []
    ];
    
    // Check if file was uploaded
    if (!isset($file) || $file['error'] === UPLOAD_ERR_NO_FILE) {
        $result['valid'] = false;
        $result['errors'][] = 'No file uploaded';
        return $result;
    }
    
    // Check for upload errors
    if ($file['error'] !== UPLOAD_ERR_OK) {
        $result['valid'] = false;
        $result['errors'][] = 'File upload error: ' . $file['error'];
        return $result;
    }
    
    // Check file size
    if ($file['size'] > $maxSize) {
        $result['valid'] = false;
        $result['errors'][] = 'File size exceeds maximum limit';
    }
    
    // Check file type
    if (!empty($allowedTypes)) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        
        if (!in_array($mimeType, $allowedTypes)) {
            $result['valid'] = false;
            $result['errors'][] = 'File type not allowed';
        }
    }
    
    return $result;
}

/**
 * Sanitize URL
 * @param string $url URL to sanitize
 * @return string|false Sanitized URL or false if invalid
 */
function sanitizeUrl($url) {
    if (empty($url)) {
        return '';
    }
    
    $url = filter_var($url, FILTER_SANITIZE_URL);
    
    if (!filter_var($url, FILTER_VALIDATE_URL)) {
        return false;
    }
    
    return $url;
}

/**
 * Generate CSRF token
 * @return string CSRF token
 */
function generateCSRFToken() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    $token = bin2hex(random_bytes(32));
    $_SESSION['csrf_token'] = $token;
    
    return $token;
}

/**
 * Validate CSRF token
 * @param string $token Token to validate
 * @return bool True if valid
 */
function validateCSRFToken($token) {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Clean input array recursively
 * @param array $data Input array
 * @return array Cleaned array
 */
function cleanInputArray($data) {
    $cleaned = [];
    
    foreach ($data as $key => $value) {
        if (is_array($value)) {
            $cleaned[$key] = cleanInputArray($value);
        } else {
            $cleaned[$key] = sanitizeString($value);
        }
    }
    
    return $cleaned;
}
?>
