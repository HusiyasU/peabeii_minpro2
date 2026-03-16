# 🚗 Tuning Car Rental

> Aplikasi manajemen armada rental mobil berbasis Flutter dengan integrasi **Supabase** — mendukung autentikasi, penyimpanan data cloud, dan upload foto.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Database-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-00E5FF?style=flat-square)](https://flutter.dev/multi-platform)

---

## 📖 Deskripsi Aplikasi

**Tuning Car Rental** adalah aplikasi manajemen armada kendaraan untuk bisnis rental mobil. Pengguna dapat mendaftarkan akun, login, lalu mengelola data mobil (tambah, lihat, edit, hapus) secara real-time melalui database Supabase. Setiap pengguna hanya dapat melihat dan mengelola data miliknya sendiri.

---

## 📸 Screenshot

<table>
  <tr>
    <td align="center"><b>🌙 Dark Mode</b></td>
    <td align="center"><b>☀️ Light Mode</b></td>
    <td align="center"><b>➕ Form Tambah</b></td>
  </tr>
  <tr>
    <td><img src="" alt="Home Dark Mode" width="100%"/></td>
    <td><img src="" alt="Home Light Mode" width="100%"/></td>
    <td><img src="" alt="Form Tambah Mobil" width="100%"/></td>
  </tr>
</table>

---

## ✨ Fitur Aplikasi

| Fitur | Keterangan |
|---|---|
| 🔐 **Register & Login** | Autentikasi menggunakan Supabase Auth |
| 🚘 **Tambah Mobil** | Input nama, warna, harga + foto dari galeri |
| 📋 **Lihat Armada** | Menampilkan daftar mobil dari Supabase secara real-time |
| ✏️ **Edit Mobil** | Perbarui data dan foto kendaraan |
| 🗑️ **Hapus Mobil** | Konfirmasi dialog sebelum menghapus |
| 📷 **Upload Foto** | Gambar tersimpan di Supabase Storage (web-compatible) |
| 🌙 **Dark & Light Mode** | Toggle tema langsung dari halaman utama |
| 🔔 **Snackbar Notifikasi** | Notifikasi berhasil saat create, update, dan delete |
| 🔒 **Row Level Security** | Setiap user hanya akses data miliknya |
| 🌐 **Cross-Platform** | Berjalan di Web, Android, dan iOS |

---

## 🧩 Widget yang Digunakan

### Layout & Navigation
- `CustomScrollView` + `SliverAppBar` — scrollable app bar yang pinned
- `SliverList.builder` — list armada yang efisien
- `SliverToBoxAdapter` — elemen non-list dalam scroll view
- `Navigator` + `PageRouteBuilder` — navigasi antar halaman dengan animasi custom

### Input & Form
- `TextFormField` — input nama, warna, harga dengan validasi
- `Form` + `GlobalKey<FormState>` — manajemen state form
- `FilteringTextInputFormatter` — hanya angka untuk field harga
- `GestureDetector` — tap area untuk photo picker dan tombol custom

### Animasi
- `AnimationController` + `FadeTransition` + `SlideTransition` — animasi halaman masuk
- `ScaleTransition` — animasi card saat muncul (stagger per index)
- `AnimatedContainer` — transisi smooth pada field fokus dan tombol
- Custom `AnimationController` untuk FAB pulse ring

### Visual
- `Container` dengan `BoxDecoration` — card dengan border, gradient, shadow
- `ClipRRect` — sudut melengkung pada gambar
- `LinearGradient` — header, tombol, neon line
- `CustomPaint` — grid pattern dekoratif di area foto kosong
- `Image.network` — tampil foto dari Supabase Storage
- `Image.memory` — preview foto sebelum upload (web-compatible)
- `CircularProgressIndicator` — loading state

### Dialog & Feedback
- `Dialog` custom — konfirmasi hapus
- `SnackBar` — notifikasi sukses/error untuk create, update, delete
- `HapticFeedback` — respons sentuhan

### State & Stream
- `setState` — local state management
- `StreamBuilder<AuthState>` — auth gate reaktif
- `SingleTickerProviderStateMixin` — provider untuk AnimationController

---

## 🛠️ Tech Stack

| | |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Storage | Supabase Storage |
| Font | Google Fonts (Orbitron + Rajdhani) |
| Image Picker | `image_picker` |
| Env | `flutter_dotenv` |

---

## 📁 Struktur Folder

```
lib/
├── main.dart                  # Entry point, ThemeMode toggle, AuthGate
├── models/
│   └── car.dart               # Model data Car dengan fromJson/toJson
├── services/
│   └── supabase_service.dart  # CRUD + Auth + Image Upload ke Supabase
├── theme/
│   └── app_theme.dart         # ThemeData dark/light + AppColors extension
└── pages/
    ├── auth_page.dart         # Halaman Login & Register
    ├── home_page.dart         # Halaman List Armada
    └── form_page.dart         # Halaman Tambah / Edit Mobil
```

---

## ⚙️ Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/username/tuning-car-rental.git
cd tuning-car-rental
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

Buka [supabase.com](https://supabase.com), buat project baru, lalu jalankan isi file `supabase_setup.sql` di **SQL Editor** Supabase.

### 4. Konfigurasi `.env`

Buat file `.env` di root project:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> ⚠️ File `.env` sudah ada di `.gitignore` — **jangan di-commit ke GitHub**.

### 5. Jalankan Aplikasi

```bash
# Web
flutter run -d chrome

# Android / iOS
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  image_picker: ^1.0.7
  supabase_flutter: ^2.3.4
  flutter_dotenv: ^5.1.0
  cached_network_image: ^3.3.1
```

---

## 🗃️ Skema Database

```sql
Table: cars
├── id          uuid (PK, auto)
├── user_id     uuid (FK → auth.users)
├── name        text
├── color       text
├── price       text
├── image_url   text (nullable)
└── created_at  timestamptz
```

Row Level Security aktif — setiap user hanya bisa akses data miliknya sendiri.

---

<div align="center">
  Dibuat dengan ❤️ menggunakan Flutter & Supabase
</div>
