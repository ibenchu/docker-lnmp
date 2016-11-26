FROM php:fpm
MAINTAINER HuadongZuo <admin@zuohuadong.cn>
RUN apt-get update

# Install modules : GD mcrypt iconv
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libpq-dev \
    && docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd



# install php pdo_mysql redis
RUN docker-php-ext-install pdo_mysql mysqli iconv mbstring json mcrypt opcache fileinfo
RUN echo "opcache.enable_cli=1" >>  /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
    # && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

# install php pdo_pgsql
RUN docker-php-ext-install pdo_pgsql pgsql


# install swoole
RUN pecl install swoole redis
RUN docker-php-ext-enable swoole
RUN docker-php-ext-enable redis

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer



# log to /var/www/log
# RUN mkdir -p /var/www/log
# RUN echo "error_log = /var/www/log/php_error.log" > /usr/local/etc/php/conf.d/log.ini
RUN  mkdir /home/wwwroot && mkdir /home/log && mkdir /home/log/php
RUN echo "log_errors = On" >> /usr/local/etc/php/conf.d/log.ini \
    && echo "error_log=/home/log/php" >> /usr/local/etc/php/conf.d/log.ini
RUN  chown -R www-data.www-data /home/wwwroot /home/log

COPY php.ini /usr/local/etc/php/
COPY php-fpm.conf /usr/local/etc/php/
EXPOSE 9000 9501 9502 9503 9504 9505 9506 9507 9508 9509 9510
# add user additional conf for apache & php
# RUN echo "" >> /usr/local/php/conf.d/additional.ini
# RUN echo "" >> /etc/apache2/conf-enabled/additional.conf
#RUN sed -i -e 's/listen = 127.0.0.1:9000/listen = 9000/' /usr/local/php/etc/php-fpm.d/www.conf
# set system timezone & php timezone
# @TODO
# ENTRYPOINT ["/usr/local/php/sbin/php-fpm", "-F", "-c", "/usr/local/php/lib/php.ini"]
CMD ["php-fpm"]