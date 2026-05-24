# Production Deployment Plan

This document defines the production deployment plan for the app using GitHub, Docker Compose, Coolify, Traefik, and a VPS.

## Goal

Deploy the app from a dedicated `production` branch while keeping all real secrets outside the public GitHub repository.

Production target:

```text
Frontend: https://zora.coolify.depsproject.my.id
Backend:  https://api.zora.coolify.depsproject.my.id
Coolify:  https://coolify.depsproject.my.id
```

## Branch Strategy

Use two main branches:

```text
main       = development branch
production = deployment branch used by Coolify
```

Create the production branch:

```bash
git checkout main
git pull
git checkout -b production
git push -u origin production
```

After development changes are ready:

```bash
git checkout production
git merge main
git push
```

Coolify should deploy from:

```text
branch: production
```

## Secret Handling

Because the repository is public, never commit real `.env` files or credentials.

The repository may contain:

```text
.env.example
laravel-backend/.env.example
```

The repository must not contain:

```text
.env
laravel-backend/.env
```

The `.gitignore` should include:

```gitignore
.env
.env.*
laravel-backend/.env
laravel-backend/.env.*
!.env.example
!laravel-backend/.env.example
```

Real production values should be stored in Coolify environment variables or shared variables.

## Docker Compose Environment Pattern

Production Docker Compose should read values from environment variables injected by Coolify.

Use this style:

```yaml
environment:
  APP_KEY: ${APP_KEY}
  DB_PASSWORD: ${DB_PASSWORD}
  OPENROUTER_API_KEY: ${OPENROUTER_API_KEY}
```

Avoid hardcoded production secrets:

```yaml
environment:
  DB_PASSWORD: personal_branding_app
  MYSQL_ROOT_PASSWORD: root
```

Local defaults are acceptable only when they are not production secrets and are clearly safe.

## Required Coolify Variables

### Backend

```env
APP_NAME=Zora
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.zora.coolify.depsproject.my.id
APP_KEY=base64:YOUR_GENERATED_LARAVEL_KEY

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=personal_branding_app
DB_USERNAME=personal_branding_app
DB_PASSWORD=YOUR_STRONG_DB_PASSWORD

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database

AI_PROVIDER=openrouter
AI_MODEL=deepseek/deepseek-chat-v3.1:free
OPENROUTER_API_KEY=YOUR_OPENROUTER_KEY
GEMINI_API_KEY=

FRONTEND_URL=https://zora.coolify.depsproject.my.id
CORS_ALLOWED_ORIGINS=https://zora.coolify.depsproject.my.id
```

Generate the Laravel `APP_KEY`:

```bash
php artisan key:generate --show
```

### MySQL

```env
MYSQL_DATABASE=personal_branding_app
MYSQL_USER=personal_branding_app
MYSQL_PASSWORD=YOUR_STRONG_DB_PASSWORD
MYSQL_ROOT_PASSWORD=YOUR_STRONG_ROOT_PASSWORD
```

`MYSQL_PASSWORD` and Laravel `DB_PASSWORD` must match.

### Frontend

Because the backend uses a separate subdomain:

```env
API_BASE_URL=https://api.zora.coolify.depsproject.my.id/api
```

Do not put private API keys, database passwords, or Laravel keys in frontend variables. Frontend values are visible to browser users after build.

## DNS Setup

Add DNS records for the app.

Recommended:

```text
Type: A
Name: zora.coolify
Value: VPS_PUBLIC_IP

Type: A
Name: api.zora.coolify
Value: VPS_PUBLIC_IP
```

Alternative if DNS provider supports it:

```text
Type: CNAME
Name: zora.coolify
Target: coolify.depsproject.my.id

Type: CNAME
Name: api.zora.coolify
Target: coolify.depsproject.my.id
```

## Coolify Domains

Assign domains in Coolify:

```text
frontend service -> https://zora.coolify.depsproject.my.id
backend service  -> https://api.zora.coolify.depsproject.my.id
```

Coolify uses Traefik and its own Docker networking, so the app does not need to define a custom external Traefik network unless Coolify specifically requires it.

Inside the Docker Compose stack, containers can still talk by service name:

```env
DB_HOST=mysql
```

The browser cannot use Docker service names like `backend` or `mysql`; it must use a public URL such as:

```env
API_BASE_URL=https://api.zora.coolify.depsproject.my.id/api
```

## CORS Plan

CORS is needed because the frontend and backend use different origins:

```text
https://zora.coolify.depsproject.my.id
https://api.zora.coolify.depsproject.my.id
```

Laravel CORS config is located at:

```text
laravel-backend/config/cors.php
```

The backend should allow:

```env
CORS_ALLOWED_ORIGINS=https://zora.coolify.depsproject.my.id
```

If `config/cors.php` does not currently read `CORS_ALLOWED_ORIGINS`, update it before production deployment.

The app currently appears to use API token authentication, so normal CORS allow-origin configuration should be enough.

If the app later uses cookie/session authentication across subdomains, also configure:

```env
SESSION_DOMAIN=.coolify.depsproject.my.id
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=none
SANCTUM_STATEFUL_DOMAINS=zora.coolify.depsproject.my.id
```

## Database Persistence

Coolify should keep MySQL data in a persistent volume.

Do not run destructive reset commands in production unless intentionally wiping data.

Avoid:

```bash
docker compose down -v
php artisan migrate:fresh
php artisan migrate:fresh --seed
```

Use normal migrations for production:

```bash
php artisan migrate --force
```

## Deployment Checklist

1. Create and push the `production` branch.
2. Make sure real `.env` files are ignored and not committed.
3. Make sure Docker Compose reads production values from `${VARIABLE_NAME}`.
4. Add frontend, backend, and MySQL variables in Coolify.
5. Configure DNS records for frontend and backend domains.
6. Assign domains to the correct Coolify services.
7. Deploy from the `production` branch.
8. Run Laravel migrations:

```bash
php artisan migrate --force
```

9. Test frontend:

```text
https://zora.coolify.depsproject.my.id
```

10. Test backend:

```text
https://api.zora.coolify.depsproject.my.id/api
```

## Production Rules

- GitHub stores code and placeholder config only.
- Coolify stores real production secrets.
- Frontend variables are not secret.
- Backend variables may contain secrets.
- Database passwords, AI keys, and Laravel `APP_KEY` must never be committed.
- Deployments should happen by merging `main` into `production`, then pushing `production`.
