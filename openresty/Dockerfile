FROM openresty/openresty
ADD  nginx.conf      /etc/openrestyt/nginx/nginx.conf
ADD  sites-enabled/*    /etc/nginx/conf.d/
RUN  mkdir /opt/htdocs && mkdir /opt/log && mkdir /opt/log/nginx
RUN  chown -R www-data.www-data /home/wwwroot /opt/log

VOLUME ["/opt"]