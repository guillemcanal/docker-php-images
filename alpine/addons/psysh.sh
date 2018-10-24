#!/bin/sh
set -e

install() {
	curl -s -L  https://psysh.org/psysh -o /usr/local/bin/psysh
	chmod +x /usr/local/bin/psysh
}

case "$1" in
	install) 	install ;;
esac
