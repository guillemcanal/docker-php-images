#!/bin/ash
set -e

install() {
	apk add --no-cache --update gmp
	apk add --no-cache --update --virtual .gmp-deps gmp-dev
	docker-php-ext-install gmp
	apk del --no-cache .gmp-deps
}

case "$1" in
	install) 	install ;;
esac
