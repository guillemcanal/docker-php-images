#!/bin/ash
set -e

install() {
	apk add --no-cache --update libzmq
	apk add --no-cache --update --virtual .zmq-deps zeromq-dev
	yes '' | pecl install zmq-beta
	docker-php-ext-enable zmq
	apk del --no-cache .zmq-deps
}

case "$1" in
	install) 	install ;;
esac
