#!/usr/bin/env bash
SCRIPT_FILENAME=$(basename "$0")

# Environmental specific environment file
if [[ -f /var/www/html/.deploy/envs/${DEPLOY_ENVIRONMENT}.env ]]; then
    echo "Using ${DEPLOY_ENVIRONMENT}.env"
    cp .deploy/envs/"${DEPLOY_ENVIRONMENT}".env /var/www/html/.env
    chown nginx:nginx /var/www/html/.env
fi

if [[ "${DEPLOY_ENVIRONMENT}" != "development" ]]; then
    echo "Optimizing opcache"
    echo "opcache.max_accelerated_files = 130987" >> /usr/local/etc/php/conf.d/docker-vars.ini
    echo "realpath_cache_size=4096K" >> /usr/local/etc/php/conf.d/docker-vars.ini
    echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/docker-vars.ini
fi

echo "Performing migrations"
su nginx -c "php bin/console --no-interaction doctrine:migrations:migrate"

echo "Clearing cache"
su nginx -c "php bin/console cache:clear"

if [[ "${DEPLOY_ENVIRONMENT}" != "development" ]]; then
    echo "Warming up cache"
    su nginx -c "php bin/console cache:warmup"
fi
