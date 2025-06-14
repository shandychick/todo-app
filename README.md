# 📘 Aplikasi To-Do List Homework

Aplikasi ini adalah aplikasi **To-Do List Homework** berbasis **Flutter** sebagai frontend dan **Laravel** sebagai backend API, menggunakan **MySQL** untuk menyimpan data. Aplikasi ini memudahkan pengguna untuk mencatat, mengelola, dan menyelesaikan tugas-tugas mereka secara efisien.

## 📝 Deskripsi Aplikasi

Aplikasi terdiri dari beberapa halaman:
- **Halaman Homework** – Menampilkan seluruh daftar tugas.
- **Form Tambah Tugas** – Untuk menambahkan tugas baru.
- **Form Edit Tugas** – Untuk mengubah tugas yang belum selesai dan belum lewat deadline.
- **Fitur Pencarian Tugas** – Untuk mencari berdasarkan nama atau status tugas.

**Aturan Aplikasi:**
- Tugas yang sudah **selesai** atau sudah **lewat deadline** tidak bisa diedit.
- Tugas masih bisa dihapus atau bisa membuat tugas baru.

**Database (MySQL):**
Menggunakan satu tabel:

CREATE TABLE tugas (
id_tugas INT AUTO_INCREMENT PRIMARY KEY,
nama_tugas VARCHAR(255) NOT NULL,
deskripsi TEXT,
deadline DATE,
status VARCHAR(50)
);


**API Backend (Laravel):**
- Menampilkan semua tugas (`GET`)
- Menambahkan tugas (`POST`)
- Mengedit tugas (`PUT`)
- Menghapus tugas (`DELETE`)
- Mencari tugas berdasarkan nama/status (`GET` dengan query parameter)

## 💻 Software yang Digunakan

- **Visual Studio Code** – untuk coding
- **Laragon** – sebagai server lokal dan database MySQL
- **Flutter SDK** – untuk membangun aplikasi Android
- **Laravel** – backend REST API
- **MySQL** – penyimpanan data

## ⚙️ Cara Instalasi & Menjalankan

1. **Aktifkan Laragon**
   - Jalankan Apache & MySQL.

2. **Jalankan Laravel (Backend):**
   - Buka folder Laravel project.
   - Di terminal:
     ```
     composer install
     cp .env.example .env
     php artisan key:generate
     php artisan migrate
     php artisan serve
     ```
   - Pastikan konfigurasi `.env` sudah sesuai.

3. **Jalankan Flutter (Frontend):**
   - Buka folder Flutter.
   - Di terminal:
     ```
     flutter pub get
     flutter run
     ```
   - Pastikan emulator Android atau perangkat fisik aktif.

## 🎥 Demo Aplikasi

Silakan rekam penggunaan aplikasi menggunakan **Snipping Tool Video** atau screen recorder ringan lainnya.

🔗 Link Demo Video: [https://youtu.be/WnbkK2JI8HM?si=GDzvKYbackV7ESk8]

## 👤 Identitas Pembuat

- **Nama:** QISRA ADENA ISAURA  
- **Absen:** 26  
- **Kelas:** XI RPL 2  
- **Sekolah:** SMK NEGERI 1 BANTUL  

> Aplikasi ini tidak menggunakan sistem login. Semua data tugas disimpan langsung di database tanpa autentikasi pengguna.
