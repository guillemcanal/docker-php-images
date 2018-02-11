#!/bin/bash
set -e

# https://secure.php.net/gpg-keys.php
declare -A gpgKeys=(
	# https://wiki.php.net/todo/php72
	# pollita & remi
	# https://secure.php.net/downloads.php#gpg-7.2
	# https://secure.php.net/gpg-keys.php#gpg-7.2
	[7.2]='1729F83938DA44E27BA0F4D3DBDB397470D12172 B1B44D8F021E4E2D6021E995DC9FF8D3EE5AF27F'

	# https://wiki.php.net/todo/php71
	# davey & krakjoe
	# pollita for 7.1.13 for some reason
	# https://secure.php.net/downloads.php#gpg-7.1
	# https://secure.php.net/gpg-keys.php#gpg-7.1
	[7.1]='A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 1729F83938DA44E27BA0F4D3DBDB397470D12172'

	# https://wiki.php.net/todo/php70
	# ab & tyrael
	# https://secure.php.net/downloads.php#gpg-7.0
	# https://secure.php.net/gpg-keys.php#gpg-7.0
	[7.0]='1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3'

	# https://wiki.php.net/todo/php56
	# jpauli & tyrael
	# https://secure.php.net/downloads.php#gpg-5.6
	# https://secure.php.net/gpg-keys.php#gpg-5.6
	[5.6]='0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3'
)
# see https://secure.php.net/downloads.php

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

travisEnv=
for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"

	# "7", "5", etc
	majorVersion="${rcVersion%%.*}"
	# "2", "1", "6", etc
	minorVersion="${rcVersion#$majorVersion.}"
	minorVersion="${minorVersion%%.*}"

	dockerfiles=()

	for suite in stretch jessie alpine; do
		[ -d "$version/$suite" ] || continue
		alpineVer="${suite#alpine}"

		baseDockerfile=Dockerfile-debian.template
		if [ "${suite#alpine}" != "$suite" ]; then
			baseDockerfile=Dockerfile-alpine.template
		fi

		for variant in cli apache fpm zts; do
			[ -d "$version/$suite/$variant" ] || continue
			{ cat "$baseDockerfile"; } > "$version/$suite/$variant/Dockerfile"

			sed -ri \
			-e 's!%%PHP_VARIANT%%!'"$variant"'!' \
			-e 's!%%PHP_SUITE%%!'"$suite"'!' \
			-e 's!%%PHP_SHORT_VERSION%%!'"$majorVersion.$minorVersion"'!' \
			"$version/$suite/$variant/Dockerfile"

			# automatic `-slim` for stretch
			# TODO always add slim once jessie is removed
			sed -ri \
				-e 's!%%DEBIAN_SUITE%%!'"${suite/stretch/stretch-slim}"'!' \
				-e 's!%%ALPINE_VERSION%%!'"$alpineVer"'!' \
				"$version/$suite/$variant/Dockerfile"
			dockerfiles+=( "$version/$suite/$variant/Dockerfile" )
		done
	done

	newTravisEnv=
	for dockerfile in "${dockerfiles[@]}"; do
		dir="${dockerfile%Dockerfile}"
		dir="${dir%/}"
		variant="${dir#$version}"
		variant="${variant#/}"
		newTravisEnv+='\n  - VERSION='"$version VARIANT=$variant"
	done
	travisEnv="$newTravisEnv$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
