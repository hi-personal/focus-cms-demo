FROM php:8.3-cli

# System packages
RUN apt-get update && apt-get install -y git unzip libzip-dev libpng-dev libjpeg-dev libwebp-dev libxml2-dev libicu-dev libonig-dev default-mysql-client && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli mbstring zip exif dom intl gd opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Build-time változók
ARG DEV_UID
ARG DEV_GID
ARG DEV_USER

# Dinamikus user létrehozása
RUN id -u ${DEV_UID} >/dev/null 2>&1 || \
    groupadd -g ${DEV_GID} ${DEV_USER} && \
    useradd -u ${DEV_UID} -g ${DEV_GID} -m ${DEV_USER}

USER ${DEV_USER}
WORKDIR /var/www/focuscms

CMD ["sleep", "infinity"]