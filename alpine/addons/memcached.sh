#!/bin/ash
set -e

install() {
	MEMCACHED_DEPS="zlib-dev libmemcached-dev cyrus-sasl-dev"
	apk add --no-cache --update libmemcached-libs zlib
	apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS
    yes '' | pecl install memcached
    docker-php-ext-enable memcached
    apk del .memcached-deps
}

case "$1" in
	install) 	install ;;
esac

