# PANDUAN UPLOAD API KE cPanel
## Grand Hotel - UAS Mobile Computing
## Muhammad Arya Fatthurahman

---

## 🔐 AKSES cPanel

### Login cPanel
- **URL**: https://kilimanjaro.iixcp.rumahweb.net:2083/
- **Username**: bere9277
- **Password**: 7gTn5pvegnZc61

---

## 📁 LANGKAH UPLOAD FILE

### 1. Buat Database MySQL

1. Login ke cPanel
2. Buka **MySQL Databases**
3. Buat database baru: `bere9277_hotel`
4. Buat user database: `bere9277_admin` dengan password yang aman
5. Tambahkan user ke database dengan **ALL PRIVILEGES**

### 2. Import SQL Schema

1. Buka **phpMyAdmin** dari cPanel
2. Pilih database `bere9277_hotel`
3. Klik tab **Import**
4. Upload file `api/database.sql`
5. Klik **Go** untuk menjalankan

### 3. Upload API Files

1. Buka **File Manager** di cPanel
2. Masuk ke folder `public_html`
3. Buat folder baru: `api`
4. Upload semua file dari folder `api/`:
   - `config.php`
   - `users.php`
   - `hotels.php`
   - `reservations.php`
   - `articles.php`
   - `food.php`

### 4. Update Config

Edit `config.php` di cPanel dan sesuaikan:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'bere9277_hotel');
define('DB_USER', 'bere9277_admin');
define('DB_PASS', 'YOUR_NEW_PASSWORD');
```

---

## 🔗 API ENDPOINTS

Base URL: `https://[your-domain]/api/`

### Users API (`users.php`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `?action=register` | Register user baru |
| POST | `?action=login` | Login user |
| GET | `?action=profile&id=1` | Get profile user |
| POST | `?action=update` | Update profile |
| DELETE | `?id=1` | Delete user |

### Hotels API (`hotels.php`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | | List semua hotel |
| GET | `?action=detail&id=1` | Detail hotel |
| GET | `?action=search&city=Jakarta` | Search hotel |
| POST | `?action=create` | Tambah hotel |
| DELETE | `?id=1` | Hapus hotel |

### Reservations API (`reservations.php`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | | List semua reservasi |
| GET | `?action=user&user_id=1` | Reservasi user |
| POST | `?action=create` | Buat reservasi |
| POST | `?action=cancel` | Batalkan reservasi |

### Articles API (`articles.php`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | | List artikel |
| GET | `?action=detail&id=1` | Detail artikel |
| GET | `?action=category&category=promo` | Artikel by kategori |

### Food API (`food.php`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | | List menu makanan |
| GET | `?action=featured` | Menu unggulan |
| GET | `?action=category&category=main_course` | Menu by kategori |

---

## 📱 UPDATE FLUTTER APP

Setelah API di-deploy, update `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://[your-domain]/api';
```

---

## 📊 DATABASE TABLES (5 Tables)

1. **users** - Data pengguna (login, register)
2. **hotels** - Data hotel/kamar
3. **reservations** - Data reservasi/booking
4. **articles** - Artikel & berita
5. **food_menu** - Menu makanan restoran

---

## ✅ CHECKLIST UAS

- [x] Minimal 3 Database Tables ✓ (Ada 5)
- [x] Message/Dialog ✓
- [x] Snackbar ✓
- [x] Judul Aplikasi ✓
- [x] Artikel ✓
- [x] Container ✓
- [x] List Data ✓
- [x] Login ✓
- [x] Button ✓
- [x] TextField ✓
- [x] Shared Preferences ✓
- [x] Image (Local & Network) ✓
- [x] API penghubung database ✓
- [x] 5 Menu dengan minimal 3 File ✓

---

## 🔄 GITHUB

Repository: https://github.com/AryaFatthurahman1/project_hotel1

### Push Changes:
```bash
git add .
git commit -m "Add complete hotel app with API"
git push origin main
```

---

**Developed by Muhammad Arya Fatthurahman**
**UAS Mobile Computing 2026**
