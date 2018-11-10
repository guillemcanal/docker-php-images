#!/usr/bin/env bash

# Initialize PHP environment variables
# By default, it will use the images build from this repo, but you can use `library/php` instead
docker_php_init() {
	local DEFAULT_PHP_VERSION="7.2"
	if [ ! -f $HOME/.docker.php_version ];then
		echo "export DOCKER_PHP_VERSION=$DEFAULT_PHP_VERSION" > $HOME/.docker.php_version
	fi

	local DEFAULT_PHP_IMAGE="${USER}/php"
	if [ ! -f $HOME/.docker.php_image ];then
		echo "export DOCKER_PHP_IMAGE=$DEFAULT_PHP_IMAGE" > $HOME/.docker.php_image
	fi

	local DEFAULT_PHP_IMAGE_VARIANT="-cli-alpine"
	if [ ! -f $HOME/.docker.php_image.variant ];then
		echo "export DOCKER_PHP_IMAGE_VARIANT=$DEFAULT_PHP_IMAGE_VARIANT" > $HOME/.docker.php_image.variant
	fi

	mkdir -p $HOME/.docker.composer

	source $HOME/.docker.php_version
	source $HOME/.docker.php_image
	source $HOME/.docker.php_image.variant
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
	echo "addons:  $(php sh -c 'echo $PHP_ADDONS_LIST')"
}

# List local PHP Docker images
docker_php_list() {
	docker images ${DOCKER_PHP_IMAGE}
}

# List remote PHP Docker images
docker_php_list_remote() {
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

# Run PHP in a Docker container
docker_php_run() {
	local DOCKER_ARGS="-v /var/run/docker.sock:/var/run/docker.sock:ro"
	if [ "$(uname -s)" = "Linux" ];then
		DOCKER_ARGS="$DOCKER_ARGS -e USER_UID=$(id -u) -e USER_GID=$(id -g)"
	else
		DOCKER_ARGS="$DOCKER_ARGS -e USER_UID=1000 -e USER_GID=1000"
	fi

	docker run --rm -it \
	-v $HOME:$HOME \
	-v $HOME/.docker.composer:/var/composer \
	-w $(pwd) \
	${DOCKER_ARGS} \
	${DOCKER_PHP_IMAGE}:${DOCKER_PHP_VERSION}${DOCKER_PHP_IMAGE_VARIANT} "$@"
}

docker_php_push() {
	docker push ${DOCKER_PHP_IMAGE}
}

# build a php image
docker_php_build() {
	local SCRIPT_DIR=$(docker_script_directory)
	pushd "$SCRIPT_DIR" > /dev/null
		make -e build
	popd > /dev/null
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
		info)
			docker_php_info
			;;
		update)
			docker_php_update
			;;
		list)
			docker_php_list
			;;
		list-rm)
			docker_php_list_remote
			;;
		push)
			docker_php_push
			;;
		build)
			docker_php_build
			;;
		*)
			docker_php_run "$@"
			;;
	esac
}

docker_script_directory() {
	SOURCE="${BASH_SOURCE[0]}"
	while [ -h "$SOURCE" ]; do
		DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
		SOURCE="$(readlink "$SOURCE")"
		[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
	done

	echo "$(cd -P "$( dirname "$SOURCE" )" && pwd )"
}

main() {
	docker_php_init
	docker_php "$@"
}

main "$@"

