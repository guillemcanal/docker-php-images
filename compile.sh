#!/bin/bash


main() {
	PHP_DIST="${PHP_DIST:-alpine}"
	PHP_MINOR_VERSION="${PHP_MINOR_VERSION:-7.2}"
	PHP_VARIANT="${PHP_VARIANT:-cli}"

	# compile addons install commands
	TMP_SCRIPTS=$(mktemp)
	ADDONS_PATH="${PHP_DIST}/addons"
	for ADDON_NAME in "$@"; do
		if [ -f "${ADDONS_PATH}/${ADDON_NAME}.sh" ];then
			echo "    # install ${ADDON_NAME}" >> $TMP_SCRIPTS
			
			cat ${ADDONS_PATH}/${ADDON_NAME}.sh \
			| sed -n '/^install()/,/^}/p' 							`: extract the content of the install function` \
			| sed '/^[[:space:]]*$/d' 								`: remove empty lines` \
			| sed '1d;$d' 											`: remove the function definition` \
			| sed 's/;then$/N;s/\n/lol/' \
			| sed -E 's/^([[:space:]])([[:alpha:]])/\1\&\& \2/g'	`: add '&&' characters when necessary` \
			| sed -E '/\\$/! s/$/ \\/g'								`: add a \ character when necessary` \
			| sed -E 's/	/    /g' 								`: replace tabs with spaces` \
			>> $TMP_SCRIPTS

			echo "" >> $TMP_SCRIPTS
		fi
	done

	cat "Dockerfile.${PHP_DIST}.template" \
	| sed "s|<%PHP_MINOR_VERSION%>|${PHP_MINOR_VERSION}|g" \
	| sed "s|<%PHP_VARIANT%>|${PHP_VARIANT}|g" \
	| sed "/# addons/r $TMP_SCRIPTS"
}

main "$@"