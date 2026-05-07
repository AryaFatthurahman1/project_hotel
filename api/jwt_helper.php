<?php
/**
 * Enhanced JWT Implementation for PHP (No Composer required)
 * Features: Token expiration, stronger security, proper error handling
 */
class JWT {
    // Use environment variable for secret key
    private static $secret_key = null;
    private static $algorithm = 'HS256';
    private static $token_expiration = 3600; // 1 hour in seconds

    private static function getSecretKey() {
        if (self::$secret_key === null) {
            self::$secret_key = defined('JWT_SECRET_KEY') ? JWT_SECRET_KEY : 'GrandHotel_SecretKey_2026_Kilimanjaro_Hosting_Secure_JWT_Token';
        }
        return self::$secret_key;
    }

    public static function encode($payload, $expiration = null) {
        if ($expiration === null) {
            $expiration = time() + self::$token_expiration;
        }
        
        // Add standard claims
        $payload['iat'] = time(); // Issued at
        $payload['exp'] = $expiration; // Expiration time
        $payload['iss'] = 'grand-hotel-api'; // Issuer
        
        $header = json_encode(['typ' => 'JWT', 'alg' => self::$algorithm]);
        $payload = json_encode($payload);

        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::getSecretKey(), true);
        $base64UrlSignature = self::base64UrlEncode($signature);

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function decode($jwt) {
        if (empty($jwt)) {
            throw new Exception('Token is required');
        }

        $tokenParts = explode('.', $jwt);
        if (count($tokenParts) != 3) {
            throw new Exception('Invalid token structure');
        }
        
        try {
            $header = base64_decode(self::base64UrlDecode($tokenParts[0]));
            $payload = base64_decode(self::base64UrlDecode($tokenParts[1]));
            $signature_provided = $tokenParts[2];

            if (!$header || !$payload) {
                throw new Exception('Invalid token encoding');
            }

            $payload_data = json_decode($payload, true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('Invalid token payload');
            }

            // Check expiration
            if (isset($payload_data['exp']) && time() > $payload_data['exp']) {
                throw new Exception('Token has expired');
            }

            // Verify signature
            $base64UrlHeader = self::base64UrlEncode($header);
            $base64UrlPayload = self::base64UrlEncode($payload);
            $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::getSecretKey(), true);
            $base64UrlSignature = self::base64UrlEncode($signature);

            if (!hash_equals($base64UrlSignature, $signature_provided)) {
                throw new Exception('Invalid token signature');
            }

            return $payload_data;
        } catch (Exception $e) {
            throw new Exception('Token validation failed: ' . $e->getMessage());
        }
    }

    public static function validateToken($jwt) {
        try {
            $payload = self::decode($jwt);
            return [
                'valid' => true,
                'payload' => $payload
            ];
        } catch (Exception $e) {
            return [
                'valid' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    public static function refreshToken($jwt) {
        try {
            $payload = self::decode($jwt);
            
            // Remove old time claims
            unset($payload['iat']);
            unset($payload['exp']);
            
            // Generate new token with fresh expiration
            return self::encode($payload);
        } catch (Exception $e) {
            throw new Exception('Cannot refresh token: ' . $e->getMessage());
        }
    }

    private static function base64UrlEncode($data) {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }

    private static function base64UrlDecode($data) {
        return base64_decode(str_replace(['-', '_'], ['+', '/'], $data));
    }

    public static function setSecretKey($key) {
        if (empty($key) || strlen($key) < 32) {
            throw new Exception('Secret key must be at least 32 characters long');
        }
        self::$secret_key = $key;
    }

    public static function setTokenExpiration($seconds) {
        if ($seconds < 300) { // Minimum 5 minutes
            throw new Exception('Token expiration must be at least 300 seconds');
        }
        self::$token_expiration = $seconds;
    }
}
?>
