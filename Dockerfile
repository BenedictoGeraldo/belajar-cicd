# --- TAHAP 1: Build Dependencies (Composer) ---

FROM composer:2.5 AS vendor

WORKDIR /app

COPY . .

# Install dependensi production
RUN composer install --no-interaction --no-dev --optimize-autoloader

# --- TAHAP 2: Final Image (PHP-FPM) ---
# Mulai dari image PHP-FPM yang ringan
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install ekstensi PHP yang umum dibutuhkan Laravel
RUN docker-php-ext-install pdo pdo_mysql bcmath

# Salin file dependensi (vendor) dari tahap "vendor"
COPY --from=vendor /app/vendor/ ./vendor/

# Ini memastikan kita mendapatkan file yang "bersih" dari build stage
COPY --from=vendor /app/ .

# Setel kepemilikan file agar web server bisa menulis ke storage
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port yang digunakan oleh PHP-FPM
EXPOSE 9000
CMD ["php-fpm"]