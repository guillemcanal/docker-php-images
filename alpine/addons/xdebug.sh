#!/bin/ash
set -e

install() {
	XDEBUG_VERSION=$(php -r 'print version_compare(PHP_VERSION, "7.0.0", ">=") ? "2.6.0" : "2.5.5";')
	pecl install xdebug-${XDEBUG_VERSION}
	docker-php-ext-enable xdebug
}

setenv() {
	export XDEBUG_CONFIG_DEFAULT="remote_enable=On remote_host=172.17.0.1 idekey=docker"
	if [ ! -z "${XDEBUG}" ];then
		export XDEBUG_CONFIG=${XDEBUG_CONFIG_DEFAULT}
	fi
}

case "$1" in
	setenv)		setenv ;;
	install)	install ;;
esac
