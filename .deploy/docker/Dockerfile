FROM acweblabs/nginx-php8.1-fpm:${DOCKER_PHP_8_1_IMAGE_TAG}
MAINTAINER A&C systems <webdev.administration@ac-systems.com>

COPY --chown=nginx:nginx . /var/www/html
COPY .deploy/configs/nginx/application.conf /etc/nginx/conf.d/application.conf
COPY .deploy/cron/crontab /var/spool/cron/crontabs/nginx

WORKDIR /var/www/html
