#!/bin/ash
set -e

install() {
	apk --no-cache add imagemagick-dev pcre-dev libtool
	yes '' | pecl install imagick
	docker-php-ext-enable imagick
}

case "$1" in
	install) 	install ;;
esac
