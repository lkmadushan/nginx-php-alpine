FROM alpine:edge

MAINTAINER Kalpa Perera

# Install packages from stable repo's
RUN apk --no-cache add supervisor curl

# Install packages from testing repo's
RUN apk --no-cache add php7 php7-fpm php7-pdo php7-pdo_mysql php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-ctype \
    php7-tokenizer php7-json php7-mbstring php7-gd php7-session nginx \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure PHP-FPM
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY www.conf /etc/php7/php-fpm.d/www.conf
COPY php.ini /etc/php7/conf.d/php.ini

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default /etc/nginx/conf.d/default.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Application directory
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]