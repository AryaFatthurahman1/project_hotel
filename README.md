<<<<<<< HEAD
# Grand Hotel - Mobile Application
**UAS Mobile Computing 2026**  
**Developed by: Muhammad Arya Fatthurahman**

---

## 📱 Tentang Aplikasi

Grand Hotel adalah aplikasi mobile berbasis Flutter untuk sistem reservasi hotel yang dilengkapi dengan fitur restaurant, artikel, dan admin dashboard. Aplikasi ini terintegrasi dengan backend PHP + MySQL yang di-hosting di cPanel.

---

## ✨ Fitur Lengkap (Checklist UAS)

### ✅ Requirement Wajib

#### **3 Poin Minimum (a-k):**
- [x] **a) Message/Alert Dialog** - Konfirmasi logout, error handling
- [x] **b) Snackbar** - Notifikasi interaktif di seluruh aplikasi
- [x] **c) Judul Aplikasi** - "Grand Hotel" di AppBar
- [x] **d) Artikel** - Screen khusus artikel dengan kategori
- [x] **e) Container** - Digunakan di header, card, dan komponen UI
- [x] **f) List Data** - Hotel list, food menu, articles
- [x] **g) Login** - Authentication dengan email & password
- [x] **h) Button** - Custom button component & floating action button
- [x] **i) TextField** - Custom text field dengan validasi
- [x] **j) Shared Preferences** - Menyimpan session user
- [x] **k) Image (Local & Network)** - Assets lokal + CachedNetworkImage

#### **Database & API:**
- [x] **Minimal 3 Database Tables** - ✓ Ada 5 tables:
  1. `users` - Data pengguna
  2. `hotels` - Data hotel/kamar
  3. `reservations` - Data booking
  4. `articles` - Artikel & berita
  5. `food_menu` - Menu restaurant
  
- [x] **API untuk penghubung database** - ✓ PHP REST API lengkap
- [x] **Hosting** - cPanel Rumahweb (kilimanjaro.iixcp.rumahweb.net)

#### **Menu & File:**
- [x] **5 Menu dengan minimal 3 File** - ✓ Ada 10+ screen:
  1. `login_screen.dart` - Login
  2. `register_screen.dart` - Register
  3. `home_screen.dart` - Dashboard utama
  4. `hotel_list_screen.dart` - List hotel
  5. `hotel_detail_screen.dart` - Detail hotel
  6. `article_screen.dart` - Artikel & berita
  7. `food_menu_screen.dart` - Menu restaurant
  8. `profile_screen.dart` - Profil user
  9. `admin_dashboard_screen.dart` - Admin panel
  10. Dan banyak lagi...

---

## 🎯 Fitur Tambahan (Advanced)

### Backend Security:
- ✅ **JWT Token** - Library JWT di `jwt_helper.php`
- ✅ **SQL Injection Prevention** - PDO Prepared Statements
- ✅ **XSS Protection** - JSON safe output
- ✅ **Input Validation** - Backend validation
- ✅ **File Upload Security** - Extension filter & unique naming

### Frontend Features:
- ✅ **Cached Network Images** - Performance optimization
- ✅ **Bottom Navigation** - Easy navigation
- ✅ **Drawer Menu** - Side menu
- ✅ **Pull to Refresh** - Data refresh
- ✅ **Loading States** - User feedback
- ✅ **Error Handling** - Graceful failures
- ✅ **Responsive Design** - Adaptive layouts

### Admin Dashboard:
- ✅ **Statistics Overview** - Total users, hotels, revenue
- ✅ **Recent Activities** - Latest reservations
- ✅ **CRUD Ready** - Infrastructure untuk Create, Read, Update, Delete

---

## 🗂️ Struktur Project

```
project_hotel1/
├── api/                      # Backend PHP Files (Upload ke cPanel)
│   ├── config.php           # Database configuration
│   ├── database.sql         # SQL schema dengan sample data
│   ├── users.php            # Users API (login, register)
│   ├── hotels.php           # Hotels API (CRUD)
│   ├── reservations.php     # Reservations API
│   ├── articles.php         # Articles API
│   ├── food.php             # Food Menu API
│   ├── dashboard.php        # Admin Dashboard API
│   ├── upload.php           # Image Upload Handler
│   └── jwt_helper.php       # JWT Token Library
│
├── lib/
│   ├── main.dart            # Entry point aplikasi
│   ├── models/              # Data models
│   │   ├── user_model.dart
│   │   ├── hotel_model.dart
│   │   ├── article_model.dart
│   │   ├── food_model.dart
│   │   └── reservation_model.dart
│   ├── screens/             # UI Screens (10+ screens)
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── hotel_list_screen.dart
│   │   ├── hotel_detail_screen.dart
│   │   ├── article_screen.dart
│   │   ├── food_menu_screen.dart
│   │   ├── profile_screen.dart
│   │   └── admin_dashboard_screen.dart
│   ├── services/            # Business logic
│   │   ├── api_service.dart      # REST API calls
│   │   └── auth_service.dart     # Authentication logic
│   ├── widgets/             # Reusable widgets
│   │   ├── custom_button.dart
│   │   └── custom_text_field.dart
│   └── utils/
│       └── colors.dart      # App color palette
│
├── assets/
│   └── images/              # Local images
│       ├── hotel_lobby.png
│       ├── hotel_room.png
│       └── food_featured.png
│
├── PANDUAN_UPLOAD.md        # Panduan upload ke cPanel
├── PANDUAN_UPDATE_KEAMANAN.md  # Panduan keamanan & fitur baru
└── pubspec.yaml             # Dependencies
```

---

## 🚀 Cara Menjalankan Project

### A. Setup Backend (cPanel)

1. **Login ke cPanel**
   - URL: https://kilimanjaro.iixcp.rumahweb.net:2083/
   - Username: `bere9277`
   - Password: `7gTn5pvegnZc61`

2. **Buat Database MySQL**
   - Buka **MySQL Databases**
   - Buat database: `bere9277_hotel`
   - Buat user: `bere9277_admin` (set password kuat)
   - Assign user ke database dengan ALL PRIVILEGES

3. **Import SQL Schema**
   - Buka **phpMyAdmin**
   - Pilih database `bere9277_hotel`
   - Import file `api/database.sql`

4. **Upload API Files**
   - Buka **File Manager**
   - Masuk ke folder `public_html`
   - Buat folder `api`
   - Upload semua file dari folder `api/` project
   - Buat folder `api/uploads` dan set permission **755**

5. **Update Config**
   - Edit `api/config.php`
   - Sesuaikan DB_NAME, DB_USER, DB_PASS

### B. Setup Flutter App

1. **Clone Repository**
   ```bash
   git clone https://github.com/AryaFatthurahman1/project_hotel1
   cd project_hotel1
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API URL**
   - Edit `lib/services/api_service.dart`
   - Ganti `baseUrl` dengan domain Anda

4. **Run Application**
   ```bash
   flutter run
   ```

---

## 📊 Database Schema

### 1. Users Table
```sql
id, full_name, email, password, phone, role, is_active, created_at
```

### 2. Hotels Table
```sql
id, name, description, address, city, price_per_night, rating, 
image_url, facilities, room_type, is_available, total_rooms
```

### 3. Reservations Table
```sql
id, user_id, hotel_id, check_in_date, check_out_date, 
total_nights, total_price, guest_count, status, payment_status
```

### 4. Articles Table
```sql
id, title, content, excerpt, image_url, author, category, views
```

### 5. Food_Menu Table
```sql
id, name, description, price, category, image_url, is_featured
```

---

## 🔐 API Endpoints

### Authentication
- `POST /users.php?action=register` - Register user baru
- `POST /users.php?action=login` - Login user

### Hotels
- `GET /hotels.php` - List semua hotel
- `GET /hotels.php?action=detail&id={id}` - Detail hotel
- `GET /hotels.php?action=search&city={city}` - Search hotel

### Reservations
- `POST /reservations.php?action=create` - Buat reservasi
- `GET /reservations.php?action=user&user_id={id}` - Reservasi user

### Articles
- `GET /articles.php` - List artikel
- `GET /articles.php?action=detail&id={id}` - Detail artikel
- `GET /articles.php?action=category&category={cat}` - By kategori

### Food Menu
- `GET /food.php` - List menu
- `GET /food.php?action=featured` - Menu unggulan

### Admin
- `GET /dashboard.php` - Dashboard statistics

### Upload
- `POST /upload.php` - Upload gambar (multipart/form-data)

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.2
  google_fonts: ^6.1.0
  provider: ^6.1.1
  intl: ^0.19.0
  http: ^1.2.0
  cached_network_image: ^3.3.1
```

---

## 🎨 Design System

### Color Palette
- **Primary**: `#1A237E` (Deep Royal Blue)
- **Secondary**: `#C5CAE9` (Light Blue)
- **Accent**: `#FFD700` (Gold)
- **Background**: `#F5F5F5` (Light Grey)

### Typography
- **Font Family**: Poppins (Google Fonts)

---

## 🔒 Security Checklist

- ✅ SQL Injection Prevention (PDO Prepared Statements)
- ✅ XSS Protection (JSON safe output)
- ✅ JWT Token Support
- ✅ File Upload Validation
- ✅ Input Sanitization
- ✅ Password Hashing Ready (gunakan `password_hash` di production)

---

## 📝 Git Commands

```bash
# Add all changes
git add .

# Commit changes
git commit -m "Add complete hotel app with API"

# Push to GitHub
git push origin main
```

---

## 🎓 UAS Checklist

### Persyaratan Utama:
- [x] Minimal 3 Database Tables ✓ (5 tables)
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

### Fitur Tambahan (Bonus):
- [x] CRUD Complete Infrastructure
- [x] Admin Dashboard
- [x] JWT Token Support
- [x] File Upload
- [x] Security Best Practices
- [x] Responsive Design
- [x] Error Handling
- [x] Beautiful UI/UX

---

## 📞 Support & Contact

**Developer**: Muhammad Arya Fatthurahman  
**Repository**: https://github.com/AryaFatthurahman1/project_hotel1  
**Email**: arya@example.com

---

## 📄 License

Project ini dibuat untuk keperluan UAS Mobile Computing 2026.

---

**© 2026 Muhammad Arya Fatthurahman - Grand Hotel Application**
=======
# THE EMERALD IMPERIAL - Hotel Stay Luxury App

A Ultra-Premium Hotel Booking and Management System built with Flutter and PHP.

## Features
- **Ultra-Luxury UI**: Emerald & Gold theme with cinematic animations.
- **Advanced Dashboard**: Real-time sales statistics and travel notes.
- **Smart Login**: Easy access with secure token-based authentication.
- **Dual Connection**: Auto-switching between localhost and production hosting.
- **Complete API**: Full-featured backend for users, hotels, articles, and bookings.

## Production Credentials
- **URL**: [https://arya.bersama.cloud/](https://arya.bersama.cloud/)
- **DB Name**: `bere9277_db_arya`
- **DB User**: `bere9277_user_arya`
- **DB Pass**: `aryafatturahman123`

## Login Shortcuts
- **Admin**: `arya` / `123`
- **Personal**: `aryafatthurahman4@gmail.com` / `arya123`

## Prepared by
**Muhammad Arya Fatthurahman**
2023230006
UAS Mobile Computing
>>>>>>> 30c03fa7cf4dc403b71d85c91d158c310909a7e9
