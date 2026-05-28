FROM composer:2.8 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --optimize-autoloader

COPY . .

RUN composer dump-autoload --optimize --no-dev

FROM php:8.3-fpm-alpine

RUN apk add --no-cache bash fcgi icu-dev libzip-dev oniguruma-dev \
    && docker-php-ext-install bcmath pcntl pdo_mysql pdo_sqlite zip \
    && docker-php-ext-enable opcache

WORKDIR /var/www/html

COPY --from=vendor /app /var/www/html
COPY docker/entrypoint.sh /usr/local/bin/backend-entrypoint
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/99-opcache.ini

RUN chmod +x /usr/local/bin/backend-entrypoint \
    && mkdir -p storage/app/public storage/framework/{cache,sessions,testing,views} storage/logs bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

USER www-data

ENTRYPOINT ["backend-entrypoint"]
CMD ["php-fpm", "-F"]
