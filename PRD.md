# PRD - Zora Personal Branding AI

## 1. Product Overview

Zora Personal Branding AI adalah aplikasi Flutter Web yang membantu customer membangun fondasi personal branding secara bertahap. Aplikasi memandu customer dari discovery identitas diri, positioning, analisis SWOT, premise, content pillars, ide konten, hingga script generation.

Frontend berjalan di Flutter Web. Backend berjalan di Laravel API dengan MySQL. Semua data penting disimpan berdasarkan `users.id`, bukan email atau provider login.

## 2. Product Goal

Tujuan utama Zora adalah membantu customer yang belum punya arah personal branding untuk:

- Mengidentifikasi kekuatan, minat, peluang, dan kebutuhan audiens.
- Mendapat rekomendasi profile name, category, dan micro niche.
- Menyusun premise dan content pillars.
- Membuat ide konten berdasarkan content pillars.
- Menghasilkan script dari ide konten.
- Menyimpan riwayat script.
- Melanjutkan onboarding dari progress yang sudah tersimpan.
- Menggunakan email/password atau Google sebagai metode login.

## 3. Target User

Customer adalah aktor utama aplikasi. Tidak ada role admin di aplikasi saat ini.

Karakteristik customer:

- Creator pemula atau profesional yang ingin membangun personal brand.
- Membutuhkan panduan terstruktur untuk menentukan niche.
- Ingin menghasilkan ide konten dan script dengan bantuan AI.
- Dapat memakai aplikasi sebagai guest, email/password user, atau Google-linked user.

## 4. Current Platform

- Frontend: Flutter Web
- State management: Provider
- Dependency injection: GetIt
- Backend: Laravel API
- Database: MySQL
- Auth: Laravel bearer token plus Google OAuth callback flow
- AI provider: configurable backend provider with optional fallback provider
- Local frontend URL: `http://localhost:8080`
- Local backend URL: `http://localhost:8000/api`
- Production frontend URL: `https://zora.coolify.depsproject.my.id`
- Production backend URL: `https://api.zora.coolify.depsproject.my.id/api`

## 5. High-Level Architecture

```text
Flutter Web
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

## 6. Repository Structure

```text
personal-brand-ai/
├── lib/
│   ├── core/
│   │   ├── network/api_client.dart
│   │   ├── platform/
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
│   ├── app/Services/
│   ├── database/migrations/
│   └── routes/api.php
├── docker-compose.yml
├── README.md
└── PRD.md
```

## 7. Authentication

### 7.1 Email and Password

Functional requirements:

- Customer dapat register dengan email, password, dan full name.
- Customer dapat login dengan email dan password.
- Customer dapat logout.
- Sistem menampilkan pesan error jika credential salah.
- Sistem menampilkan pesan error jika email sudah terdaftar.
- Token dan user aktif disimpan di `shared_preferences`.
- Saat app dibuka, Flutter memvalidasi token tersimpan ke `/api/me`.

### 7.2 Guest Usage

Functional requirements:

- Jika belum login dan endpoint protected dipanggil, Flutter dapat membuat guest session otomatis.
- Guest account menggunakan email `guest-<uuid>@local.test`.
- Guest dapat menjalankan onboarding dan generate konten.
- Aplikasi dapat menampilkan reminder login pada interval penggunaan tertentu.

### 7.3 Google Sign-In

Google adalah metode login tambahan untuk user account yang sama, bukan identitas app yang terpisah.

Functional requirements:

- Customer dapat login/register dengan Google dari auth screen.
- Customer email/password dengan email Google yang sama dapat login via Google tanpa duplicate user.
- Customer yang sudah login dengan email berbeda dapat menghubungkan Google dari Settings.
- Settings menampilkan status Google connection dan email Google yang terhubung.
- Normal Google login tidak otomatis merge akun dengan email berbeda.
- Profile name, user profile, brand profile, content ideas, dan generated scripts tetap terkait ke `users.id`.

Google OAuth behavior:

1. Flutter membuka backend route `/auth/google/redirect`.
2. Google redirect ke `/api/auth/google/callback`.
3. Backend validasi token Google, resolve user, issue API token, lalu redirect ke frontend.
4. Flutter membaca callback token, restore session melalui `/api/me`, lalu masuk ke flow dashboard/onboarding yang sama.

## 8. Core User Flow

### 8.1 Initial Flow

1. Customer membuka aplikasi.
2. Splash screen memeriksa session atau OAuth callback.
3. Jika belum ada sesi, customer diarahkan ke pemilihan bahasa.
4. Customer memilih bahasa.
5. Customer masuk ke welcome screen.
6. Customer mulai onboarding atau login/register.

### 8.2 Onboarding Flow

1. Customer mengisi nama.
2. Customer upload foto profil lokal.
3. Customer mengisi identity finder:
   - what I love
   - what I am good at
   - what the world needs
   - what I can be paid for
4. Sistem menyimpan user profile.
5. Sistem generate rekomendasi AI:
   - profile names
   - categories
   - micro niches
   - monetization options
6. Customer memilih:
   - profile name
   - category
   - micro niche
7. Customer mengisi SWOT.
8. Sistem generate premise options.
9. Customer memilih premise.
10. Customer mengisi target audience dan tone of voice.
11. Sistem generate content pillars.
12. Customer menerima content pillars.
13. Customer masuk ke dashboard.

### 8.3 Dashboard Flow

- Home menampilkan ringkasan strategy dan akses cepat.
- Strategy menampilkan brand profile, Ikigai, SWOT, premise, monetization suggestions, dan content pillars.
- Content/history menampilkan generated scripts dan content workflow.
- Settings menampilkan account info, language, Google connection, support links, dan logout.

### 8.4 Content Creation Flow

1. Customer memilih content pillar.
2. Customer memilih jumlah ide konten.
3. Sistem generate ide konten.
4. Ide yang berhasil diparse disimpan ke backend.
5. Customer membuka detail ide.
6. Customer generate script.
7. Script tersimpan ke history.
8. Customer dapat membuka detail script.
9. Customer dapat menghapus script.

## 9. Feature Requirements

### 9.1 Language Selection

- Aplikasi menampilkan Bahasa Indonesia dan English.
- Pilihan bahasa memengaruhi localizations.
- Bahasa digunakan saat request AI melalui `languageCode`.

### 9.2 Profile Setup

- Customer mengisi nama lengkap.
- Customer dapat memilih foto profil.
- Nama disimpan ke user profile.
- Foto profil saat ini dikelola di state aplikasi dan belum menjadi upload backend permanen.

### 9.3 Identity Finder

- Customer mengisi empat field personal discovery.
- `what_i_can_be_paid_for` boleh kosong atau berisi jawaban lemah seperti "idk".
- Sistem tetap dapat meminta AI menyimpulkan monetization options dari konteks Ikigai lain.
- Jawaban user asli tetap dipertahankan.
- AI monetization suggestions disimpan terpisah di brand profile.

### 9.4 Onboarding Persistence

- Progress onboarding disimpan step by step.
- Accepted user choices disimpan ke backend.
- AI suggestions bersifat temporary sampai diterima/dipilih user.
- Aplikasi membedakan onboarding not started, in progress, dan completed.
- Dashboard tidak boleh dianggap complete hanya karena sebagian profile terisi.

### 9.5 AI Generation

- Backend menerima request Flutter di `/process-ai`.
- Backend memilih provider utama dari env.
- Backend dapat fallback ke provider kedua ketika provider utama gagal karena quota, rate limit, timeout, atau service unavailable.
- Backend mencatat metadata source/provider/model untuk onboarding answers.
- Supported actions:
  - `generate_identity`
  - `generate_premise`
  - `generate_pillars`
  - `generate_ideas`
  - `generate_script`

### 9.6 Content Ideas and Scripts

- Customer dapat generate ide konten berdasarkan brand profile dan content pillar.
- Parsed content ideas disimpan user-scoped.
- Customer dapat generate script dari satu idea.
- Generated scripts disimpan user-scoped.
- Delete script harus rollback di UI jika API gagal.

## 10. API Requirements

Base URL lokal:

```text
http://localhost:8000/api
```

Base URL produksi:

```text
https://api.zora.coolify.depsproject.my.id/api
```

### Public Endpoints

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/health` | Cek status API |
| POST | `/register` | Register customer |
| POST | `/login` | Login customer |
| GET | `/auth/google/redirect` | Mulai Google OAuth login |
| GET | `/auth/google/callback` | Callback Google OAuth |

### Protected Endpoints

Protected endpoint membutuhkan token Bearer.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/me` | Ambil user aktif |
| POST | `/logout` | Logout user |
| GET | `/auth/google/status` | Ambil status dan email Google connected |
| POST | `/auth/google/link` | Mulai explicit Google account linking |
| GET | `/user-profile` | Ambil user profile |
| PUT | `/user-profile` | Simpan user profile |
| GET | `/brand-profile` | Ambil brand profile |
| PUT | `/brand-profile` | Simpan brand profile |
| GET | `/onboarding-progress` | Ambil progress onboarding |
| POST | `/onboarding-answers` | Simpan accepted onboarding answer |
| POST | `/process-ai` | Proses AI generation |
| POST | `/content-ideas` | Simpan ide konten |
| GET | `/generated-scripts` | Ambil riwayat script |
| POST | `/generated-scripts` | Simpan generated script |
| DELETE | `/generated-scripts/{id}` | Hapus generated script |

## 11. Data Model

Database utama aplikasi menggunakan MySQL melalui Laravel Eloquent ORM. Source of truth untuk struktur database saat ini adalah migration di `laravel-backend/database/migrations/`. File `supabase_schema.sql` bersifat historis dan tidak digunakan sebagai acuan utama versi Laravel + MySQL saat ini.

Semua data penting aplikasi disimpan berdasarkan `users.id`. Email dan Google account hanya dipakai sebagai identitas login, bukan sebagai primary reference untuk data personal branding.

### 11.1 Database Relationship Overview

```text
users
├── user_profiles        one-to-one
├── brand_profiles       one-to-one
├── social_accounts      one-to-many
├── onboarding_answers   one-to-many
├── content_ideas        one-to-many
└── generated_scripts    one-to-many
```

Relationship detail:

- `users.id` menjadi primary key utama untuk customer.
- `user_profiles.user_id` adalah foreign key ke `users.id` dan bersifat unique, sehingga satu user hanya memiliki satu user profile.
- `brand_profiles.user_id` adalah foreign key ke `users.id` dan bersifat unique, sehingga satu user hanya memiliki satu brand profile.
- `social_accounts.user_id` adalah foreign key ke `users.id`, digunakan untuk menyimpan koneksi OAuth seperti Google.
- `onboarding_answers.user_id` adalah foreign key ke `users.id`, digunakan untuk menyimpan progress onboarding per step.
- `content_ideas.user_id` adalah foreign key ke `users.id`, digunakan untuk menyimpan ide konten yang dihasilkan.
- `generated_scripts.user_id` adalah foreign key ke `users.id`, digunakan untuk menyimpan riwayat script yang dihasilkan.
- Semua foreign key utama menggunakan `cascadeOnDelete`, sehingga data turunan user ikut terhapus jika user dihapus.

### 11.2 Table Structure

### users

Purpose: menyimpan akun customer utama.

Key fields:

- `id` bigint unsigned primary key
- `name` string
- `email` string unique
- `email_verified_at` timestamp nullable
- `password` string
- `api_token` string nullable unique
- `remember_token` string nullable
- `created_at` timestamp
- `updated_at` timestamp

Notes:

- `api_token` disimpan dalam bentuk hash dan digunakan untuk bearer token authentication.
- Guest account tetap disimpan sebagai row di `users` dengan email format `guest-<uuid>@local.test`.

### social_accounts

Purpose: menyimpan metode login OAuth seperti Google.

Key fields:

- `id` bigint unsigned primary key
- `user_id` foreign key ke `users.id`
- `provider` string
- `provider_user_id` string
- `provider_email` string nullable
- `created_at` timestamp
- `updated_at` timestamp

Constraints:

- unique `provider + provider_user_id`
- unique `user_id + provider`
- cascade delete ketika user dihapus

Notes:

- Untuk Google Sign-In, `provider` bernilai `google`.
- Tabel ini memastikan satu user dapat memiliki koneksi Google tanpa membuat duplikasi user baru.

### user_profiles

Purpose: menyimpan data personal discovery customer.

Key fields:

- `id` bigint unsigned primary key
- `user_id` foreign key ke `users.id`, unique
- `full_name` string nullable
- `what_i_love` text nullable
- `what_im_good_at` text nullable
- `what_the_world_needs` text nullable
- `what_i_can_be_paid_for` text nullable
- `created_at` timestamp
- `updated_at` timestamp

Constraints:

- unique `user_id`
- cascade delete ketika user dihapus

Notes:

- Tabel ini menyimpan jawaban asli user pada tahap Ikigai atau identity finder.
- `what_i_can_be_paid_for` boleh kosong atau berisi jawaban lemah seperti `idk`.

### brand_profiles

Purpose: menyimpan hasil positioning personal brand dan AI suggestions yang diterima.

Key fields:

- `id` bigint unsigned primary key
- `user_id` foreign key ke `users.id`, unique
- `selected_profile_name` string nullable
- `selected_category` string nullable
- `selected_micro_niche` string nullable
- `selected_premise` text nullable
- `tone_of_voice` string nullable
- `target_audience` text nullable
- `strengths` text nullable
- `weaknesses` text nullable
- `opportunities` text nullable
- `threats` text nullable
- `monetization_options` json nullable
- `content_pillars` json nullable
- `created_at` timestamp
- `updated_at` timestamp

Constraints:

- unique `user_id`
- cascade delete ketika user dihapus

Notes:

- Tabel ini menyimpan hasil pilihan user yang sudah diterima dari proses onboarding.
- `monetization_options` menyimpan list saran monetisasi dari AI.
- `content_pillars` menyimpan list content pillar yang diterima user.
- Onboarding dianggap completed di frontend ketika `content_pillars` sudah terisi.

### onboarding_answers

Purpose: menyimpan accepted onboarding answer per step beserta metadata AI.

Key fields:

- `id` bigint unsigned primary key
- `user_id` foreign key ke `users.id`
- `onboarding_step` string
- `selected_answer` json
- `source` string
- `model_provider` string nullable
- `model_name` string nullable
- `completed_at` timestamp
- `created_at` timestamp
- `updated_at` timestamp

Constraint:

- unique `user_id + onboarding_step`
- cascade delete ketika user dihapus

Allowed `onboarding_step` values:

- `user_profile`
- `profile_name`
- `category`
- `micro_niche`
- `swot`
- `premise`
- `tone_audience`
- `content_pillars`

Allowed `source` values:

- `manual`
- `primary_ai`
- `fallback_ai`
- `default`

Notes:

- `selected_answer` menyimpan data pilihan user dalam bentuk JSON per step.
- `model_provider` dan `model_name` dipakai untuk mencatat metadata AI ketika jawaban berasal dari hasil AI.
- Tabel ini membantu aplikasi melanjutkan onboarding dari progress yang sudah tersimpan.

### content_ideas

Purpose: menyimpan ide konten yang dihasilkan.

Key fields:

- `id` bigint unsigned primary key
- `user_id` foreign key ke `users.id`
- `pillar` string nullable
- `title` string nullable
- `angle` text nullable
- `content_overview` text nullable
- `viral_potential` string nullable
- `insight` text nullable
- `platform` string default `Multi-Platform`
- `created_at` timestamp
- `updated_at` timestamp

Constraints:

- cascade delete ketika user dihapus

Notes:

- Data pada tabel ini berasal dari hasil parsing AI action `generate_ideas`.
- Ide konten tetap user-scoped agar setiap customer hanya mengakses ide miliknya sendiri.

### generated_scripts

Purpose: menyimpan script hasil generate.

Key fields:

- `id` bigint unsigned primary key
- `user_id` foreign key ke `users.id`
- `title` string
- `platform` string default `Multi-Platform`
- `script` longText
- `original_idea_id` string nullable
- `pillar` string nullable
- `created_at` timestamp
- `updated_at` timestamp

Constraints:

- cascade delete ketika user dihapus

Notes:

- Tabel ini menyimpan riwayat script yang ditampilkan pada dashboard atau content history.
- Delete script harus memastikan script hanya dapat dihapus oleh pemilik `user_id` yang sama.

### 11.3 Laravel Support Tables

Laravel juga memiliki beberapa tabel pendukung bawaan:

- `password_reset_tokens`: tabel bawaan Laravel untuk token reset password. Fitur password reset belum menjadi requirement aktif pada versi saat ini.
- `sessions`: tabel bawaan Laravel untuk penyimpanan session. Autentikasi API aplikasi tetap menggunakan bearer token sederhana melalui `users.api_token`.
- `cache`, `cache_locks`, `jobs`, `job_batches`, dan `failed_jobs`: tabel pendukung Laravel untuk cache dan queue jika digunakan oleh framework.

Tabel pendukung tersebut bukan data utama personal branding, tetapi dapat tetap ada karena dibuat oleh migration bawaan Laravel.

## 12. Environment and Setup

### Root Flutter `.env`

File lokal root `.env` tidak dikomit. Gunakan `.env.example`.

Local Docker default:

```env
API_BASE_URL=http://localhost:8000/api
```

Production:

```env
API_BASE_URL=https://api.zora.coolify.depsproject.my.id/api
```

### Laravel `.env`

File lokal `laravel-backend/.env` tidak dikomit. Gunakan `laravel-backend/.env.example`.

Important backend env:

```env
APP_URL=http://localhost:8000
FRONTEND_URL=http://localhost:8080
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
AI_PROVIDER=gemini
AI_MODEL=gemini-2.5-flash
AI_FALLBACK_PROVIDER=openrouter
AI_FALLBACK_MODEL=
OPENROUTER_API_KEY=
GEMINI_API_KEY=
```

Production env lives in Coolify.

## 13. Local Runbook

### Docker

```bash
docker compose up --build
```

Open:

```text
http://localhost:8080
```

Backend health:

```bash
curl http://localhost:8000/api/health
```

### Manual Laravel

```bash
cd laravel-backend
php artisan migrate
php artisan serve --host=127.0.0.1 --port=8000
```

### Manual Flutter Web

```bash
flutter run -d chrome --web-hostname localhost --web-port 8080
```

## 14. Production Deployment

Production uses Coolify and deploys from the `production` branch.

Production env values must be set in Coolify, not committed:

```env
API_BASE_URL=https://api.zora.coolify.depsproject.my.id/api
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.zora.coolify.depsproject.my.id
FRONTEND_URL=https://zora.coolify.depsproject.my.id
CORS_ALLOWED_ORIGINS=https://zora.coolify.depsproject.my.id
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

Google Console production config:

```text
Authorized JavaScript origins:
https://zora.coolify.depsproject.my.id

Authorized redirect URIs:
https://api.zora.coolify.depsproject.my.id/api/auth/google/callback
```

Run migrations through normal deployment/startup:

```bash
php artisan migrate --force
```

## 15. Non-Goals for Current Version

- Admin dashboard.
- Admin account/role.
- Permanent backend profile photo upload.
- Password reset.
- Email verification flow.
- Payment/subscription.
- Social media publishing integration.
- Full production-grade auth hardening such as OAuth token revocation UI or multi-device session management.

## 16. Known Limitations

- Profile image is not persisted to backend storage.
- API token auth is intentionally simple.
- Google account disconnect is not implemented yet.
- Connected Google status shows current linked email but does not support changing provider without backend unlink support.
- CORS is permissive on `main`; production branch keeps stricter Coolify configuration.

## 17. Suggested Next Improvements

1. Add backend storage for profile image upload.
2. Add Google disconnect/change-account flow with safety checks.
3. Improve guest-to-registered account conversion.
4. Add password reset and email verification.
5. Add production observability for AI provider errors and OAuth errors.
6. Add more Flutter integration tests for Google callback and onboarding resume.
7. Add admin-free export/report feature for generated strategy output.

## 18. Important Files

Frontend:

- `lib/main.dart`
- `lib/core/network/api_client.dart`
- `lib/core/platform/browser_redirect.dart`
- `lib/core/di/service_locator.dart`
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
- `laravel-backend/app/Services/Auth/GoogleOAuthService.php`
- `laravel-backend/app/Services/Ai/`
- `laravel-backend/app/Http/Middleware/ApiTokenAuth.php`
- `laravel-backend/database/migrations/`

Docs:

- `README.md`
- `PRD.md`
- `laravel-backend/LOCAL_SETUP.md`

## 19. Prompt Context

```text
I am building Zora Personal Branding AI, a Flutter Web app with a Laravel + MySQL backend. The app helps a customer complete personal branding onboarding, generate identity suggestions, choose a niche, fill SWOT, generate a premise, generate content pillars, create content ideas, and generate scripts. There is no admin role. The backend has API token auth, Google OAuth login/linking through social_accounts, profile endpoints, brand profile endpoints, onboarding progress endpoints, AI generation endpoints with provider/fallback support, content idea endpoints, and generated script endpoints. Flutter calls Laravel through lib/core/network/api_client.dart. The local API URL is http://localhost:8000/api and production API URL is https://api.zora.coolify.depsproject.my.id/api. Please use PRD.md as the source of truth.
```
