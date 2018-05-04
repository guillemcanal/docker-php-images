#!/bin/ash
set -e

install() {
	pecl install protobuf
	docker-php-ext-enable protobuf
}

case "$1" in
	install) 	install ;;
esac

