# Local Laravel Backend Setup

This backend is separate from the Flutter app and lives in `laravel-backend`.

## Requirements

- PHP 8.3: `php`
- Composer: `/opt/homebrew/bin/composer`
- MySQL or MariaDB running locally on `127.0.0.1:3306`

The included `.env.example` expects:

```env
DB_DATABASE=personal_branding_app
DB_USERNAME=root
DB_PASSWORD=
```

## First Run

Start MySQL first. If you use XAMPP, start MySQL from the XAMPP manager app.

Then run:

```bash
cd laravel-backend
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS personal_branding_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
php artisan migrate
php artisan serve --host=127.0.0.1 --port=8000
```

The Flutter app reads:

```env
API_BASE_URL=http://127.0.0.1:8000/api
```

from the root `.env` file.

## Current API

- `POST /api/register`
- `POST /api/login`
- `POST /api/logout`
- `GET /api/me`
- `GET|PUT /api/user-profile`
- `GET|PUT /api/brand-profile`
- `POST /api/process-ai`
- `POST /api/content-ideas`
- `GET|POST /api/generated-scripts`
- `DELETE /api/generated-scripts/{id}`

`/api/process-ai` is currently a local stub so the app can be tested without Supabase. Replace `AiController` with a real AI provider integration later.
