#!/usr/bin/env sh

set -eu

cd /var/www/html

mkdir -p \
  storage/app/public \
  storage/framework/cache \
  storage/framework/sessions \
  storage/framework/testing \
  storage/framework/views \
  storage/logs \
  bootstrap/cache

if [ ! -f public/storage ]; then
  php artisan storage:link --no-interaction >/dev/null 2>&1 || true
fi

if [ "${APP_RUN_MIGRATIONS:-false}" = "true" ]; then
  attempts=0

  until php artisan migrate --force --no-interaction; do
    attempts=$((attempts + 1))

    if [ "$attempts" -ge "${APP_MIGRATION_MAX_ATTEMPTS:-20}" ]; then
      echo "Migration failed after ${attempts} attempts." >&2
      exit 1
    fi

    echo "Waiting for database... attempt ${attempts}" >&2
    sleep 3
  done
fi

if [ "${APP_RUN_STORAGE_LINK:-false}" = "true" ]; then
  php artisan storage:link --no-interaction >/dev/null 2>&1 || true
fi

if [ "${APP_RUN_OPTIMIZE:-false}" = "true" ]; then
  php artisan config:cache --no-interaction
  php artisan route:cache --no-interaction
  php artisan view:cache --no-interaction
fi

exec "$@"
