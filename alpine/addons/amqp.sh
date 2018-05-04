#!/bin/sh
set -e

install() {
	ALPINE_REPOSITORY=
	SHOULD_ADD_REPOSITORY="$(ALPINE_VERSION=$(cat /etc/alpine-release) php -r 'print version_compare(getenv("ALPINE_VERSION"), "3.6", "<=") ? "yes" : "no";')"
	if [ "$SHOULD_ADD_REPOSITORY" == "yes" ];then
		echo '@v3.7 http://dl-cdn.alpinelinux.org/alpine/v3.6/main' >> /etc/apk/repositories
		ALPINE_REPOSITORY="@v3.7"
	fi

	apk -U add rabbitmq-c${ALPINE_REPOSITORY} rabbitmq-c-dev${ALPINE_REPOSITORY} || true
	
	yes '' | pecl install amqp
	docker-php-ext-enable amqp
	
	apk del rabbitmq-c-dev${ALPINE_REPOSITORY} || true
	rm -r /var/cache/apk/*
}

case "$1" in
	install) 	install ;;
esac
