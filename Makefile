VERSION=7.2
DIST=alpine
VARIANT=cli
ADDONS=composer xdebug
IMAGE_NAME=$(USER)/php:$(VERSION)-$(VARIANT)-$(DIST)

all:
	make VERSION=5.6 build
	make VERSION=7.0 build
	make VERSION=7.1 build
	make VERSION=7.2 build
	make VERSION=7.3 build
	make VERSION=7.4 build

build:
	docker build --build-arg PHP_DIST=$(DIST) --build-arg PHP_VARIANT=$(VARIANT) --build-arg PHP_MINOR_VERSION=$(VERSION) --build-arg PHP_ADDONS_LIST="$(ADDONS)" -t $(IMAGE_NAME) -f Dockerfile.$(DIST) .
