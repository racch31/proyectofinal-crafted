FROM php:8.2-apache

# Extensión para conectar PHP con MySQL mediante PDO
RUN docker-php-ext-install pdo_mysql

# Permitir subir fotos de productos de hasta 5 MB
RUN { \
      echo "upload_max_filesize = 5M"; \
      echo "post_max_size = 6M"; \
    } > /usr/local/etc/php/conf.d/uploads.ini
