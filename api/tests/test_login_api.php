<?php
// Test script to verify login API
// Usage: Open in browser or run with: php test_login_api.php

// Test login with arya/123
$data = [
    'email' => 'arya',
    'password' => '123'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://arya.bersama.cloud/api/login.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // For testing only

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response: $response\n";

// Also test with email
echo "\n--- Testing with email ---\n";
$data2 = [
    'email' => 'arya@unsada.ac.id',
    'password' => '123'
];

$ch2 = curl_init();
curl_setopt($ch2, CURLOPT_URL, 'https://arya.bersama.cloud/api/login.php');
curl_setopt($ch2, CURLOPT_POST, true);
curl_setopt($ch2, CURLOPT_POSTFIELDS, http_build_query($data2));
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_SSL_VERIFYPEER, false);

$response2 = curl_exec($ch2);
$httpCode2 = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
curl_close($ch2);

echo "HTTP Status: $httpCode2\n";
echo "Response: $response2\n";
?>
