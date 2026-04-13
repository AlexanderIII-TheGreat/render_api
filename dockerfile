FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    zip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy project
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel setup (optional safe mode)
# Catatan: Di produksi, sebaiknya .env diatur via Environment Variables di Dashboard Render
RUN cp .env.example .env || true
RUN php artisan key:generate || true

# Membuat symbolic link untuk foto profil (PERBAIKAN FOTO)
RUN php artisan storage:link

# Permission
RUN chmod -R 775 storage bootstrap/cache

# Expose port (Render akan override biasanya)
EXPOSE 8000

# Start Laravel dengan Migrasi Otomatis (PERBAIKAN DATABASE & RUNTIME)
CMD sh -c "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=$PORT"
