#!/bin/sh

echo "${PROXY_AUTH_CREDENTIALS}" >> /etc/nginx/.htpasswd

sed -i "s/{DM_APP_NAME}/$DM_APP_NAME/g" /etc/nginx/nginx.conf
[ -f /etc/nginx/sites-enabled/api ] && sed -i "s/{PORT}/$PORT/g" /etc/nginx/sites-enabled/api
[ -f /etc/nginx/sites-enabled/frontend ] && sed -i "s/{PORT}/$PORT/g" /etc/nginx/sites-enabled/frontend

exec /usr/sbin/nginx
