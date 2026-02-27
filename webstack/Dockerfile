FROM php:8.3-cli

# System packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libxml2-dev \
    libicu-dev \
    libonig-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        zip \
        exif \
        dom \
        intl \
        gd \
        opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/focuscms

ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} istvan \
    && useradd -u ${UID} -g ${GID} -m istvan

RUN git config --global --add safe.directory /var/www/focuscms

USER istvan

CMD ["sleep", "infinity"]
