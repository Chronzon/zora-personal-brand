# Zora - Personal Branding AI

Zora is a Flutter Web application for building a personal branding strategy with AI assistance. The app guides a user from identity discovery through niche positioning, SWOT analysis, content pillars, content ideas, and script generation.

The project is built for a thesis/Skripsi workflow and uses a Laravel API plus MySQL backend so the product can run locally with Docker and deploy to production through Coolify.

## What Zora Does

- Guides users through a structured personal branding onboarding flow.
- Generates AI-assisted profile names, categories, micro niches, premises, content pillars, content ideas, and scripts.
- Stores accepted onboarding decisions so progress survives refresh, login, and deployment restarts.
- Separates user-written Ikigai answers from AI-generated monetization suggestions.
- Supports email/password authentication.
- Supports Google Sign-In and explicit Google account linking.
- Shows the connected Google email in Settings.
- Supports Bahasa Indonesia and English localization.
- Keeps generated scripts in a user-scoped history.
- Supports configurable AI providers and fallback models through backend environment variables.

## Tech Stack

- Frontend: Flutter Web
- State management: Provider
- Dependency injection: GetIt
- Backend: Laravel API
- Database: MySQL
- Auth: Laravel API bearer token plus Google OAuth callback flow
- AI providers: OpenRouter, Gemini, and local fallback behavior
- Deployment: Docker Compose, Coolify, Traefik

## Main App Flow

1. User opens the app.
2. User selects language.
3. User completes onboarding:
   - name
   - profile photo state
   - Ikigai identity finder
   - AI identity suggestions
   - selected profile name, category, and micro niche
   - SWOT
   - AI premise suggestions
   - target audience and tone of voice
   - AI content pillars
4. User reaches dashboard.
5. User can generate content ideas and scripts.
6. User can review strategy and script history.
7. User can connect Google from Settings for future login.

## Repository Structure

```text
personal-brand-ai/
├── lib/                         # Flutter app
│   ├── core/                    # networking, DI, theme, shared widgets
│   └── features/                # auth, onboarding, dashboard, content creation
├── laravel-backend/             # Laravel API
│   ├── app/Http/Controllers/Api/
│   ├── app/Models/
│   ├── app/Services/
│   ├── database/migrations/
│   └── routes/api.php
├── docker-compose.yml
├── Dockerfile.frontend
├── PRD.md
└── README.md
```

## Local Development

The default local Docker setup uses:

```text
Frontend: http://localhost:8080
Backend:  http://localhost:8000/api
MySQL:    localhost:3307
```

Create local env files from the examples:

```bash
cp .env.example .env
cp laravel-backend/.env.example laravel-backend/.env
```

For local Docker, use these important values:

```env
API_BASE_URL=http://localhost:8000/api
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000
FRONTEND_URL=http://localhost:8080
```

Start the full stack:

```bash
docker compose up --build
```

Run backend tests:

```bash
cd laravel-backend
php artisan test
```

Run Flutter checks:

```bash
flutter analyze
flutter test
```

## Google Sign-In

Google Sign-In uses a backend OAuth callback flow.

Local Google Console setup:

```text
Authorized JavaScript origins:
http://localhost:8080

Authorized redirect URIs:
http://localhost:8000/api/auth/google/callback
```

Production Google Console setup:

```text
Authorized JavaScript origins:
https://zora.coolify.depsproject.my.id

Authorized redirect URIs:
https://api.zora.coolify.depsproject.my.id/api/auth/google/callback
```

Required backend env:

```env
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

Google account data is stored in `social_accounts`. The app user identity remains in `users`, and existing profile data is preserved when Google is linked.

## AI Configuration

AI provider settings live on the Laravel backend. Flutter does not store private AI keys.

Common env values:

```env
AI_PROVIDER=openrouter
AI_MODEL=
AI_FALLBACK_PROVIDER=gemini
AI_FALLBACK_MODEL=gemini-2.5-flash
OPENROUTER_API_KEY=
GEMINI_API_KEY=
```

The backend records AI metadata for onboarding answers so the app can show whether output came from the primary provider, fallback provider, or local fallback.

## Production

Production deploys from the `production` branch through Coolify.

Production domains:

```text
Frontend: https://zora.coolify.depsproject.my.id
Backend:  https://api.zora.coolify.depsproject.my.id
```

Important production env values:

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

Do not commit real `.env` files or secrets. Store production secrets in Coolify.

## Source Of Truth

Use `PRD.md` for the detailed product requirements, current behavior, API surface, and data model.
