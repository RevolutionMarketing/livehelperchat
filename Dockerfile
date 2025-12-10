FROM php:7.4-apache

# 1. Installa i programmi di sistema e le LIBRERIE DI SVILUPPO necessarie
# La modifica importante è l'aggiunta di "libcurl4-openssl-dev" qui sotto
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    zlib1g-dev \
    libzip-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev

# 2. Installa ed abilita le estensioni PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    zip \
    gd \
    bcmath \
    mbstring \
    xml \
    curl

# 3. Abilita i moduli necessari di Apache
RUN a2enmod headers rewrite

# 4. Installa Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 5. Prepara la cartella di lavoro
WORKDIR /var/www/html

# 6. Copia i file del sito
COPY ./lhc_web /var/www/html

# 7. ESEGUI COMPOSER (Scarica il motore/vendor)
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# 8. Correggi i permessi
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
