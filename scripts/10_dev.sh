#!/usr/bin/env bash
SCRIPT_FILENAME=$(basename "$0")
echo "Running ${SCRIPT_FILENAME}"

if [[ "${DEPLOY_ENVIRONMENT}" == "development" ]]; then
    echo "Enabling SSL on dev environment"
    cat << EOF >> /etc/nginx/sites-enabled/000-default-ssl.conf
server {
  listen 443 ssl;
  ssl_certificate /etc/nginx/ssl/cert.pem;
  ssl_certificate_key /etc/nginx/ssl/key.pem;

  location / {
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Port 443;
    proxy_pass http://host.docker.internal;
  }
}
EOF
fi
