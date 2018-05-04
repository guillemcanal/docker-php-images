#!/bin/sh
set -e

install() {
	COMPOSER_HOME=/var/composer
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php composer-setup.php --filename composer --install-dir=/usr/local/bin/
	php -r "unlink('composer-setup.php');"
}

setenv() {
	export COMPOSER_HOME=/var/composer
	export PATH=$PATH:$COMPOSER_HOME/vendor/bin
}

case "$1" in
	setenv)		setenv ;;
	install) 	install ;;
esac
