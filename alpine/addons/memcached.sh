#!/bin/ash
set -e

install() {
	apk add --no-cache --update libmemcached-libs zlib
	apk add --no-cache --update --virtual .memcached-deps zlib-dev libmemcached-dev cyrus-sasl-dev
	yes '' | pecl install memcached
	docker-php-ext-enable memcached
	apk del --no-cache .memcached-deps
}

case "$1" in
	install) 	install ;;
esac

