ARG PHP_MINOR_VERSION=7.2
ARG PHP_VARIANT=cli 
ARG PHP_DIST=alpine

FROM php:$PHP_MINOR_VERSION-$PHP_VARIANT-$PHP_DIST

ARG PHP_DIST=alpine
ARG PHP_VARIANT=cli
ARG PHP_ADDONS_LIST=""
ENV PHP_ADDONS_LIST=$PHP_ADDONS_LIST

COPY ${PHP_DIST}/scripts/* ${DPHP_DISTIST}/scripts-${PHP_VARIANT}/* /usr/local/bin/
COPY ${PHP_DIST}/addons/* /php-addons/

RUN apk add --no-cache curl su-exec \
	&& docker-php-addons $PHP_ADDONS_LIST
