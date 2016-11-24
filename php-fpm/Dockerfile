FROM php:alpine


# Install modules : GD mcrypt iconv
# RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories
# RUN echo "http://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
# RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf && apk update && apk upgrade

#  RUN  apk add --no-cache  \
#         libfreetype6-dev \
#         libjpeg62-turbo-dev \
#         libmcrypt-dev \
#         libpng12-dev \
#     && docker-php-ext-install iconv mcrypt \
#     && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    # && docker-php-ext-install gd

# install php pdo_mysql
RUN docker-php-ext-install pdo pdo_mysql mysqli iconv mbstring json mcrypt opcache 
RUN echo "opcache.enable_cli=1" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# install php pdo_pgsql
RUN docker-php-ext-install pdo_pgsql pgsql

# install php composer
# RUN docker-php-ext-install composer


# install dom xml
RUN apk add --no-cache libxml2 && docker-php-ext-install dom simplexml xmlreader
# install php curl
RUN apk add --no-cache libcurl && docker-php-ext-install curl


# install swoole
RUN pecl install swoole
# RUN docker-php-ext-install swoole
# RUN docker-php-ext-enable swoole

#install redis
# ENV PHPREDIS_VERSION php7
# RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
#     && tar xfz /tmp/redis.tar.gz \
#     && rm -r /tmp/redis.tar.gz \
#     && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
#     && docker-php-ext-install redis


# log to /var/www/log
# RUN mkdir -p /var/www/log
# RUN echo "error_log = /var/www/log/php_error.log" > /usr/local/etc/php/conf.d/log.ini
RUN echo "log_errors = On" >> /usr/local/etc/php/conf.d/log.ini \
    && echo "error_log=/dev/stderr" >> /usr/local/etc/php/conf.d/log.ini

