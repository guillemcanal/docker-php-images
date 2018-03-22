#!/bin/ash
set -e

install() {
	apk add --no-cache --update icu
	apk add --no-cache --update --virtual .intl-deps icu-dev
    docker-php-ext-install intl
    apk del .intl-deps
}

case "$1" in
	install) 	install ;;
esac
