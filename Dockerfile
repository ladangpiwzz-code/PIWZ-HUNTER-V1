# ============================================
# PIWZ HUNTER - ULTIMATE DARK CONTROL PANEL
# AGENZ EDITION WITH KILLER LOADING ANIMATION
# ============================================

# Stage 1: Builder
FROM node:18-alpine AS animation-builder
WORKDIR /build
# Install tools for animation optimization
RUN npm install -g clean-css-cli uglify-js

FROM php:8.2-apache AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev zip unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring zip \
    && a2enmod rewrite

WORKDIR /var/www/html
COPY . .

# ============================================
# Production Stage
# ============================================
FROM php:8.2-apache

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring zip \
    && a2enmod rewrite headers \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Security - non-root user
RUN useradd -m -u 1000 piwzuser \
    && chown -R piwzuser:www-data /var/www/html

# Copy application
COPY --from=builder --chown=piwzuser:www-data /var/www/html /var/www/html

# Fix permissions
RUN chmod 777 /var/www/html/logs.txt \
    && chmod 777 /var/www/html/devices.json \
    && chmod 755 /var/www/html

USER piwzuser
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/ || exit 1

# Start command for Koyeb
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080} -t /var/www/html"]
