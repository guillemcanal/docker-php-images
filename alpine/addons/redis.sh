#!/bin/ash
set -e

install() {
	yes '' | pecl install redis
	docker-php-ext-enable redis
}

case "$1" in
	install) 	install ;;
esac

