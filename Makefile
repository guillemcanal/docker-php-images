VERSION=7.2
DIST=alpine
VARIANT=cli
ADDONS=composer xdebug psysh blackfire intl

all:
	make VERSION=5.6 build
	make VERSION=7.0 build
	make VERSION=7.1 build
	make VERSION=7.2 build

build:
	docker build --build-arg PHP_DIST=$(DIST) --build-arg PHP_VARIANT=$(VARIANT) --build-arg PHP_MINOR_VERSION=$(VERSION) --build-arg PHP_ADDONS_LIST="$(ADDONS)" -t $(USER)/php:$(VERSION)-$(VARIANT)-$(DIST) .
