# --- TAHAP 1: Build Dependencies (Composer) ---
FROM composer:2.5 as vendor

WORKDIR /app
# Salin hanya file yang diperlukan untuk composer install
COPY database/ database/
COPY composer.json composer.lock ./

# Install dependensi production
RUN composer install --no-interaction --no-dev --optimize-autoloader

# --- TAHAP 2: Final Image (PHP-FPM) ---
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install ekstensi PHP yang umum dibutuhkan Laravel
RUN docker-php-ext-install pdo pdo_mysql bcmath

# Salin file dependensi (vendor) dari tahap "vendor"
COPY --from=vendor /app/vendor/ ./vendor/

# Salin sisa kode aplikasi Anda
COPY . .

# Setel kepemilikan file agar web server bisa menulis ke storage
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port yang digunakan oleh PHP-FPM
EXPOSE 9000
CMD ["php-fpm"]