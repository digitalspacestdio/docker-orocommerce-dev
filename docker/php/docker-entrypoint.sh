#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ] || [ "$1" = 'symfony' ]; then
	setfacl -R -m u:php:rwX -m u:"$(whoami)":rwX /var/www
	setfacl -dR -m u:php:rwX -m u:"$(whoami)":rwX /var/www
fi

chown php:php /var/www 2> /dev/null || true
chown php:php /home/php/.composer 2> /dev/null || true
chown php:php /home/php/.npm 2> /dev/null || true
chown php:php /proc/self/fd/1
chown php:php /proc/self/fd/2

for i in "$@"; do
    i="${i//\\/\\\\}"
    i="${i//$/\\$}"
    C="$C \"${i//\"/\\\"}\""
done

HOME=/home/php su -p php -- -c "exec docker-php-entrypoint $C"
