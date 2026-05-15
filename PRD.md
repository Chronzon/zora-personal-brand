# PRD - Personal Branding Zora

## 1. Product Overview

**Personal Branding Zora** adalah aplikasi Flutter untuk membantu customer membangun fondasi personal branding secara bertahap. Aplikasi memandu customer dari input identitas diri, pemilihan positioning, analisis SWOT, pembuatan premise, content pillar, hingga pembuatan ide konten dan script.

Versi saat ini berjalan dengan frontend Flutter dan backend Laravel lokal berbasis MySQL. Aplikasi sebelumnya menggunakan Supabase, tetapi sekarang sudah diarahkan ke Laravel API agar bisa dikembangkan dan diuji secara lokal tanpa akses Supabase.

## 2. Product Goal

Tujuan utama aplikasi adalah membantu customer yang belum punya arah personal branding untuk:

- Mengidentifikasi kekuatan, minat, peluang, dan kebutuhan audiens.
- Mendapat rekomendasi nama profil, kategori, dan micro niche.
- Menyusun premise dan content pillar.
- Membuat ide konten berdasarkan pillar.
- Menghasilkan script dari ide konten.
- Menyimpan riwayat script agar bisa dipakai ulang.

## 3. Target User

### Customer

Customer adalah satu-satunya aktor aplikasi. Tidak ada role admin di aplikasi ini.

Karakteristik customer:

- Creator pemula atau profesional yang ingin membangun personal brand.
- Membutuhkan panduan terstruktur untuk menentukan niche.
- Ingin menghasilkan ide konten dan script dengan bantuan AI.
- Bisa menggunakan aplikasi sebagai guest atau dengan akun email/password.

## 4. Current Platform

- **Frontend:** Flutter
- **State management:** Provider
- **Dependency injection:** GetIt
- **Backend:** Laravel API
- **Database:** MySQL via Homebrew
- **Database GUI:** phpMyAdmin
- **Local frontend URL:** `http://127.0.0.1:3000`
- **Local backend URL:** `http://127.0.0.1:8000/api`
- **Local phpMyAdmin URL:** `http://127.0.0.1:8081`

## 5. Current Repository Structure

```text
personal-brand-ai/
├── lib/
│   ├── core/
│   │   ├── network/api_client.dart
│   │   ├── services/
│   │   ├── errors/
│   │   ├── providers/
│   │   ├── theme/
│   │   └── widgets/
│   └── features/
│       ├── auth/
│       ├── onboarding/
│       ├── dashboard/
│       └── content_creation/
├── laravel-backend/
│   ├── app/Http/Controllers/Api/
│   ├── app/Http/Middleware/
│   ├── app/Models/
│   ├── database/migrations/
│   └── routes/api.php
├── .env.example
├── pubspec.yaml
└── PRD.md
```

## 6. High-Level Architecture

```text
Flutter App
  |
  | HTTP JSON API
  v
Laravel API
  |
  | Eloquent ORM
  v
MySQL Database
```

Flutter tidak terhubung langsung ke MySQL. Flutter hanya memanggil Laravel API melalui `ApiClient`.

## 7. Authentication

### Current Behavior

- Customer dapat register dengan email, password, dan nama lengkap.
- Customer dapat login dengan email dan password.
- Customer dapat logout.
- Untuk flow guest, Flutter membuat akun guest lokal otomatis melalui endpoint register dengan email `guest-<uuid>@local.test`.
- Google login belum tersedia di backend Laravel lokal.

### Auth Storage

Token dan data user disimpan melalui `shared_preferences` dan direstore saat `SplashScreen` berjalan. Flutter memvalidasi token tersimpan ke endpoint `/api/me`; jika token tidak valid, sesi lokal dihapus dan customer diarahkan kembali ke flow awal.

## 8. Core User Flow

### 8.1 Initial Flow

1. Customer membuka aplikasi.
2. Splash screen muncul.
3. Jika belum ada sesi, customer diarahkan ke pemilihan bahasa.
4. Customer memilih bahasa.
5. Customer masuk ke welcome screen.
6. Customer mulai onboarding atau login/register.

### 8.2 Onboarding Flow

1. Customer mengisi nama.
2. Customer upload foto profil.
3. Customer mengisi identity finder:
   - What I love
   - What I'm good at
   - What the world needs
   - What I can be paid for
4. Sistem generate rekomendasi:
   - Profile names
   - Categories
   - Micro niches
5. Customer memilih:
   - Profile name
   - Category
   - Micro niche
6. Customer mengisi SWOT:
   - Strengths
   - Weaknesses
   - Opportunities
   - Threats
7. Sistem generate premise options.
8. Customer memilih premise.
9. Customer mengisi target audience dan tone of voice.
10. Sistem generate content pillars.
11. Customer masuk ke dashboard.

### 8.3 Content Creation Flow

1. Customer membuka dashboard.
2. Customer memilih content pillar.
3. Customer memilih jumlah ide konten.
4. Sistem generate ide konten.
5. Customer membuka detail ide.
6. Customer generate script dari ide.
7. Script tersimpan ke riwayat.
8. Customer dapat membuka detail script.
9. Customer dapat menghapus script.

## 9. Feature Requirements

### 9.1 Language Selection

Customer dapat memilih bahasa aplikasi.

Functional requirements:

- Aplikasi menampilkan pilihan Bahasa Indonesia dan English.
- Pilihan bahasa memengaruhi localizations aplikasi.
- Bahasa digunakan saat request AI melalui parameter `languageCode`.

### 9.2 Authentication

Functional requirements:

- Customer dapat membuat akun.
- Customer dapat login.
- Customer dapat logout.
- Sistem menampilkan pesan error jika credential salah.
- Sistem menampilkan pesan error jika email sudah terdaftar.
- Google login menampilkan pesan belum tersedia pada backend lokal.

### 9.3 Guest Usage

Functional requirements:

- Jika belum login, sistem dapat membuat sesi guest otomatis.
- Guest dapat menjalankan onboarding dan generate konten.
- Aplikasi menampilkan reminder login setiap interval penggunaan tertentu.

Current note:

- `ContentCreationProvider` menggunakan `reminderInterval = 5`.

### 9.4 Profile Setup

Functional requirements:

- Customer mengisi nama lengkap.
- Customer upload foto profil.
- Sistem menyimpan nama ke user profile.
- Foto profil saat ini hanya dikelola di state aplikasi, belum terlihat sebagai upload backend permanen.

### 9.5 Identity Finder

Functional requirements:

- Customer mengisi empat field personal discovery.
- Sistem menyimpan user profile.
- Sistem memanggil AI service untuk generate rekomendasi.
- Sistem menampilkan profile names, categories, dan micro niches.
- Customer memilih hasil rekomendasi untuk membentuk brand profile.

### 9.6 SWOT and Premise

Functional requirements:

- Customer mengisi strengths, weaknesses, opportunities, threats.
- Sistem memanggil AI service untuk membuat premise options.
- Customer memilih satu premise.
- Premise disimpan di brand profile.

### 9.7 Tone of Voice and Content Pillars

Functional requirements:

- Customer mengisi target audience.
- Customer memilih tone of voice.
- Sistem memanggil AI service untuk generate content pillars.
- Content pillars disimpan di brand profile.
- Customer diarahkan ke dashboard setelah content pillars selesai.

### 9.8 Dashboard

Functional requirements:

- Dashboard memiliki tab utama untuk home, strategy, dan content/history.
- Home menampilkan ringkasan dan akses cepat generate ide.
- Strategy menampilkan brand strategy dan content pillars.
- Content menampilkan riwayat generated scripts.
- Settings menampilkan informasi akun, pilihan bahasa, dan logout.

### 9.9 Generate Content Ideas

Functional requirements:

- Customer memilih content pillar dari dropdown.
- Customer memilih jumlah ide melalui slider.
- Sistem memanggil AI service dengan payload brand profile.
- Sistem menampilkan raw response dan parsed ideas.
- Ide yang berhasil diparse disimpan ke backend melalui endpoint content ideas.
- Jika penyimpanan ide gagal tetapi generate berhasil, ide tetap ditampilkan.

### 9.10 Generate Script

Functional requirements:

- Customer membuka detail ide konten.
- Customer menekan generate script.
- Sistem memanggil AI service dengan data ide, platform, dan brand profile.
- Script yang berhasil dibuat disimpan ke backend.
- Script masuk ke daftar riwayat.
- Customer dapat membuka detail script.
- Customer dapat menghapus script.
- Jika delete gagal, UI melakukan rollback script ke daftar.

## 10. API Requirements

Base URL lokal:

```text
http://127.0.0.1:8000/api
```

### Public Endpoints

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/health` | Cek status API |
| POST | `/register` | Register customer |
| POST | `/login` | Login customer |

### Protected Endpoints

Protected endpoint membutuhkan token Bearer.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/me` | Ambil user aktif |
| POST | `/logout` | Logout user |
| GET | `/user-profile` | Ambil user profile |
| PUT | `/user-profile` | Simpan user profile |
| GET | `/brand-profile` | Ambil brand profile |
| PUT | `/brand-profile` | Simpan brand profile |
| POST | `/process-ai` | Proses AI/stub |
| POST | `/content-ideas` | Simpan ide konten |
| GET | `/generated-scripts` | Ambil riwayat script |
| POST | `/generated-scripts` | Simpan generated script |
| DELETE | `/generated-scripts/{id}` | Hapus generated script |

## 11. Data Model

### users

Purpose: menyimpan akun customer.

Key fields:

- `id`
- `name`
- `email`
- `password`
- `api_token`
- `created_at`
- `updated_at`

### user_profiles

Purpose: menyimpan data personal discovery customer.

Key fields:

- `id`
- `user_id`
- `full_name`
- `what_i_love`
- `what_im_good_at`
- `what_the_world_needs`
- `what_i_can_be_paid_for`
- `created_at`
- `updated_at`

### brand_profiles

Purpose: menyimpan hasil positioning personal brand.

Key fields:

- `id`
- `user_id`
- `selected_profile_name`
- `selected_category`
- `selected_micro_niche`
- `selected_premise`
- `tone_of_voice`
- `target_audience`
- `strengths`
- `weaknesses`
- `opportunities`
- `threats`
- `content_pillars`
- `created_at`
- `updated_at`

### content_ideas

Purpose: menyimpan ide konten yang dihasilkan.

Key fields:

- `id`
- `user_id`
- `pillar`
- `title`
- `angle`
- `content_overview`
- `viral_potential`
- `insight`
- `platform`
- `created_at`
- `updated_at`

### generated_scripts

Purpose: menyimpan script hasil generate.

Key fields:

- `id`
- `user_id`
- `title`
- `platform`
- `script`
- `original_idea_id`
- `pillar`
- `created_at`
- `updated_at`

## 12. AI Service

Flutter menggunakan `GeminiService`, tetapi implementasi sekarang memanggil Laravel endpoint `/process-ai`.

Laravel `AiController` saat ini masih berupa local stub untuk testing tanpa Supabase. Endpoint mengembalikan mock result untuk action:

- `generate_identity`
- `generate_premise`
- `generate_pillars`
- `generate_ideas`
- `generate_script`

Future requirement:

- Ganti stub di `AiController` dengan provider AI asli, misalnya Gemini atau OpenAI.
- Simpan API key di `.env` backend, bukan di Flutter.
- Tambahkan error handling untuk rate limit, timeout, dan invalid response.

## 13. Environment and Setup

### Root Flutter `.env`

File lokal root `.env` tidak dikomit. Gunakan `.env.example` sebagai template.

```env
API_BASE_URL=http://127.0.0.1:8000/api
```

### Laravel `.env`

File lokal `laravel-backend/.env` tidak dikomit. Gunakan `laravel-backend/.env.example`.

Expected local database:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=personal_branding_app
DB_USERNAME=root
DB_PASSWORD=
```

## 14. Local Runbook

### Start MySQL

```bash
brew services start mysql
```

Check MySQL:

```bash
mysqladmin -uroot ping
mysql -uroot -e "SHOW DATABASES LIKE 'personal_branding_app';"
```

### Start Laravel API

```bash
cd /Users/devlenandyanto/Documents/Coding/Skripsi/personal-brand-ai/laravel-backend
php artisan serve --host=127.0.0.1 --port=8000
```

Check API:

```bash
curl http://127.0.0.1:8000/api/health
```

### Start Flutter Web

```bash
cd /Users/devlenandyanto/Documents/Coding/Skripsi/personal-brand-ai
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 3000
```

### Start phpMyAdmin

```bash
php -S 127.0.0.1:8081 -t /opt/homebrew/share/phpmyadmin
```

Open:

```text
http://127.0.0.1:8081
```

phpMyAdmin is configured for local config auth.

## 15. Stop Local Services

Stop MySQL:

```bash
brew services stop mysql
```

Stop Laravel, Flutter, or phpMyAdmin:

Press `Ctrl + C` or `q` in the terminal running the service.

If started by Codex/tool sessions, check ports:

```bash
lsof -nP -iTCP:3000 -sTCP:LISTEN
lsof -nP -iTCP:8000 -sTCP:LISTEN
lsof -nP -iTCP:8081 -sTCP:LISTEN
```

Then stop by PID:

```bash
kill <PID>
```

## 16. Non-Goals for Current Version

Current version does not include:

- Admin dashboard.
- Admin account/role.
- Production deployment.
- Real AI provider integration.
- Persistent token storage.
- Password reset.
- Email verification.
- Permanent profile photo upload.
- Payment/subscription.
- Social media publishing integration.

## 17. Known Limitations

- `/api/process-ai` is still a mock/stub endpoint.
- Guest accounts are stored as generated local users.
- Google login is disabled for the Laravel local backend.
- Profile image is not persisted to backend storage.
- Some Flutter analyzer warnings are still present, mostly existing lint/deprecation items.
- Laravel API token implementation is simple and suitable for local testing, not final production security.

## 18. Suggested Next Improvements

1. Replace local AI stub with real AI integration.
2. Add production-grade auth using Laravel Sanctum or Passport.
3. Add backend storage for profile image upload.
4. Improve guest-to-registered account conversion.
5. Add validation and UI states for empty/error AI responses.
6. Add more automated feature tests for Laravel endpoints.
7. Add Flutter widget/integration tests for onboarding and content generation.
9. Create deployment plan for backend and database.
10. Add PRD-linked black-box testing spreadsheet as QA artifact.

## 19. Important Files for Context

Frontend:

- `lib/main.dart`
- `lib/core/network/api_client.dart`
- `lib/core/di/service_locator.dart`
- `lib/core/services/gemini_service.dart`
- `lib/features/auth/`
- `lib/features/onboarding/`
- `lib/features/content_creation/`
- `lib/features/dashboard/`

Backend:

- `laravel-backend/routes/api.php`
- `laravel-backend/app/Http/Controllers/Api/AuthController.php`
- `laravel-backend/app/Http/Controllers/Api/ProfileController.php`
- `laravel-backend/app/Http/Controllers/Api/ContentController.php`
- `laravel-backend/app/Http/Controllers/Api/AiController.php`
- `laravel-backend/app/Http/Middleware/ApiTokenAuth.php`
- `laravel-backend/database/migrations/2026_05_03_000001_create_personal_branding_tables.php`

Docs:

- `laravel-backend/LOCAL_SETUP.md`
- `PRD.md`

## 20. Prompt Context for ChatGPT Browser

Use this summary when asking ChatGPT in browser:

```text
I am building Personal Branding Zora, a Flutter app with a Laravel + MySQL backend. The app helps a customer complete personal branding onboarding, generate identity suggestions, choose a niche, fill SWOT, generate premise, generate content pillars, create content ideas, and generate scripts. There is no admin role. The current Laravel backend is local and has API token auth, profile endpoints, brand profile endpoints, content idea endpoints, generated script endpoints, and a mock /api/process-ai endpoint. Flutter calls Laravel through lib/core/network/api_client.dart. The local API URL is http://127.0.0.1:8000/api. MySQL database is personal_branding_app. Please use this PRD as the source of truth.
```
