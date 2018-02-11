#!/usr/bin/env bash

# Initialize PHP environment variables
# By default, it will use the images build from this repo, but you can use `library/php` instead
docker_php_init() {
	local DEFAULT_PHP_VERSION="7.2"
	if [ ! -f $HOME/.docker.php_version ];then
		echo "export DOCKER_PHP_VERSION=$DEFAULT_PHP_VERSION" > $HOME/.docker.php_version
	fi

	local DEFAULT_PHP_IMAGE="${HOME}/php"
	if [ ! -f $HOME/.docker.php_image ];then
		echo "export DOCKER_PHP_IMAGE=$DEFAULT_PHP_IMAGE" > $HOME/.docker.php_image
	fi

	local DEFAULT_PHP_IMAGE_VARIANT="-alpine"
	if [ ! -f $HOME/.docker.php_image.variant ];then
		echo "export DOCKER_PHP_IMAGE_VARIANT=$DEFAULT_PHP_IMAGE_VARIANT" > $HOME/.docker.php_image.variant
	fi

	local DEFAULT_PHP_UNIX_SHELL="/bin/ash"
	if [ ! -f $HOME/.docker.php_shell ];then
		echo "export DOCKER_PHP_UNIX_SHELL=$DEFAULT_PHP_UNIX_SHELL" > $HOME/.docker.php_shell
	fi

	mkdir -p $HOME/.docker.composer

	source $HOME/.docker.php_version
	source $HOME/.docker.php_image
	source $HOME/.docker.php_image.variant
	source $HOME/.docker.php_shell
}

# Update the current image
docker_php_update() {
	local PHP_IMAGE="${DOCKER_PHP_IMAGE}:${DOCKER_PHP_VERSION}${DOCKER_PHP_IMAGE_VARIANT}"
	docker pull "$PHP_IMAGE"
}

# Display PHP info
docker_php_info() {
	echo "image:   ${DOCKER_PHP_IMAGE}"
	echo "version: ${DOCKER_PHP_VERSION}"
	echo "variant: ${DOCKER_PHP_IMAGE_VARIANT}"
}

# List Available PHP images
docker_php_available() {
	curl -s "https://registry.hub.docker.com/v1/repositories/${DOCKER_PHP_IMAGE}/tags"  | jq '.[] | .name' -r | less
}

# Change the PHP Docker image
docker_php_image() {
	local PHP_IMAGE="${1:-'library/php'}"
	echo "export DOCKER_PHP_IMAGE=$PHP_IMAGE" > $HOME/.docker.php_image
	export DOCKER_PHP_IMAGE=$PHP_IMAGE
}

# Change the PHP Docker image variant
docker_php_image_variant() {
	local PHP_IMAGE_VARIANT="${1:-'-alpine'}"
	echo "export DOCKER_PHP_IMAGE_VARIANT=$PHP_IMAGE_VARIANT" > $HOME/.docker.php_image.variant
	export DOCKER_PHP_IMAGE_VARIANT=$PHP_IMAGE_VARIANT
}

# Change the PHP Docker version
docker_php_version() {
	local PHP_VERSION="${1:-'7.2'}"
	echo "export DOCKER_PHP_VERSION=$PHP_VERSION" > $HOME/.docker.php_version
	export DOCKER_PHP_VERSION=$PHP_VERSION
}

# Run a PHP container using a UNIX Shell (bash, ash, etc...)
docker_php_shell() {
	docker run --rm -it -v $(pwd):/app -w /app --entrypoint ${DOCKER_PHP_UNIX_SHELL} ${DOCKER_PHP_IMAGE}:${DOCKER_PHP_VERSION}${DOCKER_PHP_IMAGE_VARIANT}
}

# Run PHP in a Docker container
# @TODO support Linux machine (switch to the current user)
docker_php_run () {
	docker run --rm -it -v $HOME/.docker.composer:/var/composer -v $(pwd):/app -w /app ${DOCKER_PHP_IMAGE}:${DOCKER_PHP_VERSION}${DOCKER_PHP_IMAGE_VARIANT} "$@"
}

# PHP main entrypoint
docker_php() {
	case $1 in
		version)
			shift; docker_php_version "$@"
			;;
		image)
			shift; docker_php_image "$@"
			;;
		variant)
			shift; docker_php_image_variant "$@"
			;;
		shell)
			shift; docker_php_shell "$@"
			;;
		info)
			shift; docker_php_info "$@"
			;;
		update)
			shift; docker_php_update "$@"
			;;
		available)
			shift; docker_php_available "$@"
			;;
		*)
			docker_php_run "$@"
			;;
	esac
}

docker_php_init

alias php="docker_php"

