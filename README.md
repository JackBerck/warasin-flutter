# Proyek Warasin

Warasin adalah aplikasi mobile cross-platform yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk membantu pengguna mengelola kesehatan pribadi, dengan fokus pada pengelolaan jadwal minum obat dan pencatatan riwayat kesehatan.

## 📝 Tentang Aplikasi

Aplikasi "Warasin" bertujuan untuk memberikan solusi digital yang mudah digunakan bagi pengguna untuk memantau dan mengelola aspek-aspek penting dari kesehatan mereka. Dengan antarmuka yang bersih dan fungsionalitas yang to-the-point, aplikasi ini cocok untuk berbagai kalangan, termasuk lansia yang mungkin memerlukan bantuan dalam mengingat jadwal pengobatan.

## ✨ Fitur Utama

Berdasarkan struktur proyek, berikut adalah fitur-fitur yang ada atau sedang dikembangkan:

- **Autentikasi Pengguna**: Sistem login dan registrasi untuk menjaga keamanan data pengguna.
- **Onboarding**: Panduan awal bagi pengguna baru untuk memahami cara kerja aplikasi.
- **Dashboard**: Halaman utama yang menampilkan ringkasan informasi penting.
- **Jadwal Obat**: Fitur untuk membuat, mengelola, dan mendapatkan pengingat jadwal minum obat.
- **Riwayat Kesehatan**: Pencatatan riwayat kesehatan pribadi pengguna.
- **Manajemen Profil**: Pengaturan profil dan data pengguna.
- **Notifikasi Lokal**: Pengingat real-time untuk jadwal obat, bahkan saat aplikasi tidak dibuka.

## 🚀 Teknologi yang Digunakan

- **Framework**: Flutter
- **Bahasa**: Dart
- **Backend**: Supabase (berdasarkan `supabase_client.dart`)
- **Database Lokal**: SQFlite (untuk penyimpanan data offline)
- **State Management**: (Dapat ditambahkan sesuai implementasi, misal: Provider, Riverpod, Bloc)

## ⚙️ Cara Menjalankan Proyek

Untuk menjalankan proyek ini di lingkungan lokal Anda, ikuti langkah-langkah berikut:

1.  **Prasyarat**
    - Pastikan Anda telah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install) di mesin Anda.
    - Memiliki koneksi ke Supabase atau backend lain yang sesuai.

2.  **Clone Repositori**
    ```bash
    git clone <URL_REPOSITORI_ANDA>
    cd warasin
    ```

3.  **Instalasi Dependensi**
    Jalankan perintah berikut untuk mengunduh semua dependensi yang diperlukan.
    ```bash
    flutter pub get
    ```

4.  **Konfigurasi Environment**
    - Salin file `.env.example` menjadi file baru bernama `.env`.
    - Isi variabel environment yang diperlukan di dalam file `.env`, seperti URL dan Kunci Anon Supabase Anda.
      ```env
      SUPABASE_URL=URL_ANDA
      SUPABASE_ANON_KEY=KUNCI_ANON_ANDA
      ```

5.  **Jalankan Aplikasi**
    Hubungkan perangkat atau jalankan emulator, lalu gunakan perintah berikut:
    ```bash
    flutter run
    ```

## 📁 Struktur Proyek

Proyek ini mengikuti struktur direktori yang umum pada aplikasi Flutter untuk menjaga keterbacaan dan skalabilitas kode.

```
lib/
├── core/           # Komponen inti (tema, router, config, utils)
├── features/       # Fitur-fitur aplikasi (auth, schedule, dll.)
├── services/       # Servis global (notifikasi, database)
├── app.dart        # Konfigurasi utama aplikasi
└── main.dart       # Titik masuk aplikasi
```

---
Readme ini dibuat berdasarkan analisis struktur proyek. Silakan sesuaikan lebih lanjut jika ada detail lain yang ingin ditambahkan.