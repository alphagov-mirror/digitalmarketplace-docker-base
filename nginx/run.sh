#!/bin/sh

[ "${PROXY_AUTH_CREDENTIALS}x" = "x" ] && echo 'envvar $PROXY_AUTH_CREDENTIALS not set' && exit 1
[ "${DM_APP_NAME}x" = "x" ] && echo 'envvar $DM_APP_NAME not set' && exit 1
[ "${PORT}x" = "x" ] && echo 'envvar $PORT not set' && exit 1

echo "${PROXY_AUTH_CREDENTIALS}" >> /etc/nginx/.htpasswd

sed -i "s/{DM_APP_NAME}/$DM_APP_NAME/g" /etc/nginx/nginx.conf
[ -f /etc/nginx/sites-enabled/api ] && sed -i "s/{PORT}/$PORT/g" /etc/nginx/sites-enabled/api
[ -f /etc/nginx/sites-enabled/frontend ] && sed -i "s/{PORT}/$PORT/g" /etc/nginx/sites-enabled/frontend

exec /usr/sbin/nginx
