#!/bin/ash
set -e

install() {
	apk --no-cache zeromq-dev
	yes '' | pecl install zmq-beta
	docker-php-ext-enable zmq
}

case "$1" in
	install) 	install ;;
esac
