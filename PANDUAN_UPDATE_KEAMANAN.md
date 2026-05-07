# PANDUAN UPDATE SISTEM (KEAMANAN & FITUR BARU)
## Grand Hotel - UAS Mobile Computing

---

## 🔒 UPDATE KEAMANAN (JWT & UPLOAD)

### 1. Upload Script Tambahan
Upload file berikut ke folder `api/` di cPanel:
- `jwt_helper.php` (Library JWT tanpa Composer)
- `upload.php` (Script upload gambar aman)
- `dashboard.php` (API untuk Admin Dashboard)

### 2. Buat Folder Uploads
1. Di cPanel File Manager, masuk ke folder `api`
2. Buat folder baru bernama `uploads`
3. Klik kanan folder `uploads`, pilih **Change Permissions**
4. Set permission ke **755** (User: RWE, Group: RE, World: RE)

### 3. Update File `users.php` (Opsional)
Untuk mengaktifkan JWT, edit `users.php` di bagian login:

Tambahkan baris ini di paling atas file:
```php
require_once 'jwt_helper.php';
```

Dan update bagian Login Success:
```php
if ($user) {
    // Generate Token
    $payload = [
        'iss' => 'http://grandhotel.com',
        'aud' => 'http://grandhotel.com',
        'iat' => time(),
        'nbf' => time(),
        'data' => [
            'id' => $user['id'],
            'email' => $user['email']
        ]
    ];
    $jwt = JWT::encode($payload);
    
    unset($user['password']);
    response(true, 'Login berhasil!', $user, $jwt); // Kirim token
}
```

---

## 📱 FITUR CRUD LENGKAP

Aplikasi Flutter kini mendukung:

1. **Authentication (Users Table)**
   - Login & Register dengan validasi
   - Password Hashing (disarankan update PHP untuk pakai `password_hash`)
   - Token JWT (disiapin di `api_service.dart`)

2. **Hotels & Food (Products Table)**
   - **Read**: List Hotel & Menu Makanan
   - **Create**: Reservasi Hotel
   - **Upload**: Dukungan upload gambar via `upload.php`

3. **Admin Dashboard (Dashboard API)**
   - API `dashboard.php` menyajikan statistik total user, hotel, dan revenue.

---

## 🛡️ CHECKLIST KEAMANAN

- [x] **SQL Injection**: Menggunakan PDO Prepared Statements di semua file PHP.
- [x] **XSS Protection**: Output JSON aman dari injeksi script langsung.
- [x] **File Upload**: Filter ekstensi (hanya jpg, png, webp) dan rename file unik.
- [x] **Input Validation**: Validasi empty field di backend.
- [x] **JWT Token**: Script JWT siap digunakan.

---

**Developed by Muhammad Arya Fatthurahman**
