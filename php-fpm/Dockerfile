FROM php:alpine


# Install modules : GD mcrypt iconv
RUN  && apk add --no-cache  \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# install php pdo_mysql
RUN docker-php-ext-install pdo pdo_mysql mysqli iconv mbstring json mcrypt opcache 
RUN echo "opcache.enable_cli=1" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# install php pdo_pgsql
RUN docker-php-ext-install pdo_pgsql pgsql


# install dom xml
RUN apt-get install libxml2 && docker-php-ext-install dom simplexml xmlreader
# install php curl
RUN apt-get install libcurl && docker-php-ext-install curl


# install swoole
RUN pecl install swoole
RUN docker-php-ext-enable swoole

#install redis
ENV PHPREDIS_VERSION php7
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis


# log to /var/www/log
# RUN mkdir -p /var/www/log
# RUN echo "error_log = /var/www/log/php_error.log" > /usr/local/etc/php/conf.d/log.ini
RUN echo "log_errors = On" >> /usr/local/etc/php/conf.d/log.ini \
    && echo "error_log=/dev/stderr" >> /usr/local/etc/php/conf.d/log.ini

