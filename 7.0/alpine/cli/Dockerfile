FROM php:7.0-cli-alpine

ENV COMPOSER_HOME /var/composer

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
	\
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --filename composer --install-dir=/usr/local/bin/ \
	&& php -r "unlink('composer-setup.php');" \
	\
	&& XDEBUG_VERSION=$(php -r 'print version_compare(PHP_VERSION, "7.0.0", ">=") ? "2.6.0" : "2.5.5";') \
	&& pecl install xdebug-$XDEBUG_VERSION \
	&& { \
		echo 'xdebug.remote_enable=On'; \
		echo 'xdebug.remote_connect_back=On'; \
		echo 'xdebug.remote_enable=On'; \
		echo 'xdebug.remote_host=172.17.0.1'; \
		echo 'xdebug.idekey=docker'; \
		echo ''; \
		echo 'zend_extension=xdebug.so'; \
	} | tee "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" \
	&& apk del .build-deps


