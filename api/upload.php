<?php
/**
 * File Upload Handler (Multipart)
 */
require_once 'config.php';

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');

$response = array();
$upload_dir = 'uploads/'; // Pastikan folder ini ada di cPanel (chmod 755)

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['image'])) {
        $file_name = $_FILES['image']['name'];
        $file_tmp = $_FILES['image']['tmp_name'];
        $file_type = $_FILES['image']['type'];
        $file_error = $_FILES['image']['error'];

        // Get extension
        $file_ext = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));
        $extensions = array("jpeg", "jpg", "png", "gif", "webp");

        if (in_array($file_ext, $extensions) === false) {
            response(false, "Extension not allowed, please choose a JPEG or PNG file.");
        }

        if ($file_error === 0) {
            // Generate unique name
            $new_file_name = uniqid('', true) . "." . $file_ext;
            $destination = $upload_dir . $new_file_name;

            // Move file
            if (move_uploaded_file($file_tmp, $destination)) {
                // Return full URL
                $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
                $full_url = "$protocol://$_SERVER[HTTP_HOST]" . dirname($_SERVER['REQUEST_URI']) . '/' . $destination;
                
                response(true, "File uploaded successfully", ["url" => $full_url]);
            } else {
                response(false, "Failed to move uploaded file.");
            }
        } else {
            response(false, "Error uploading file. Code: $file_error");
        }
    } else {
        response(false, "No file uploaded.");
    }
} else {
    response(false, "Invalid request method.");
}
?>
