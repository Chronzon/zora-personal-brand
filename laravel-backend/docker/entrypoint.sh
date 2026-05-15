#!/usr/bin/env bash
set -euo pipefail

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

if [ -n "${DB_HOST:-}" ]; then
    echo "Waiting for database at ${DB_HOST}:${DB_PORT:-3306}..."
    until nc -z "${DB_HOST}" "${DB_PORT:-3306}"; do
        sleep 1
    done
fi

if [ -z "${APP_KEY:-}" ]; then
    echo "APP_KEY is not set. Generating a temporary key for this container..."
    php artisan key:generate --force
fi

php artisan migrate --force
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec "$@"

