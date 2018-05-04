#!/bin/ash
set -e

install() {
	apk add --no-cache --update icu-libs
	apk add --no-cache --update --virtual .intl-deps icu-dev
	docker-php-ext-install intl
	apk del --no-cache .intl-deps
}

case "$1" in
	install) 	install ;;
esac
