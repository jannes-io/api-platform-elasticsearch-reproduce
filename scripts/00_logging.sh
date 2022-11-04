#!/usr/bin/env bash
SCRIPT_FILENAME=$(basename "$0")
echo "Running ${SCRIPT_FILENAME}"

su nginx -c "mkdir -p /var/www/html/var/log"
if [[ "${DEPLOY_ENVIRONMENT}" != "development" ]]; then
    echo "Creating symlinks in var/log directory"
    ln -sf /tmp/logpipe /var/www/html/var/log/prod.log
    ln -sf /tmp/logpipe /var/www/html/var/log/cron.log
    ln -sf /tmp/logpipe /var/www/html/var/log/dev.log
    ln -sf /tmp/logpipe /var/www/html/var/log/prod.deprecations.log
    ln -sf /tmp/logpipe /var/www/html/var/log/test.deprecations.log
fi
