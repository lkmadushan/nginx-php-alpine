FROM alpine:3.7

LABEL Kalpa Perera

RUN DEBIAN_FRONTEND=noninteractive

ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV TERM xterm

# Ensure www-data user exists
ARG PUID=82
ARG PGID=${PUID}
RUN addgroup -g ${PGID} -S www-data \
    && adduser -u ${PUID} -D -S -G www-data www-data

# Install packages from stable repo's
RUN apk --no-cache add supervisor curl

# Install packages from testing repo's
RUN apk --no-cache add php7 php7-fpm php7-pdo php7-pdo_mysql php7-pdo_sqlite php7-openssl php7-curl php7-fileinfo \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-ctype \
    php7-tokenizer php7-json php7-mbstring php7-gd php7-session php7-simplexml nginx \
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

# Configure timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

# Configure crontab
RUN (crontab -u root -l; echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1" ) | crontab -u root -

# Application directory
RUN mkdir -p /var/www/html

RUN chown -R www-data: /var/www
RUN chmod 755 /var/www

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
