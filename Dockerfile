FROM php:7.4-apache

# 1. Installa i programmi di sistema necessari (Git, Zip, Curl sono fondamentali per Composer)
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
    libxml2-dev

# 2. Installa ed abilita le estensioni PHP (il motore grafico e database)
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

# 3. Abilita i moduli necessari di Apache (per i link e i file)
RUN a2enmod headers rewrite

# 4. Installa Composer (Il gestore delle dipendenze che mancava!)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 5. Prepara la cartella di lavoro
WORKDIR /var/www/html

# 6. Copia i file del tuo sito dentro l'immagine
COPY ./lhc_web /var/www/html

# 7. ESEGUI COMPOSER (Questo scarica la cartella "vendor" automaticamente!)
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# 8. Correggi i permessi (Fondamentale per evitare l'Errore 500 sui volumi)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
