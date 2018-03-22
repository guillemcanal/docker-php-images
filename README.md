# [WIP] Docker PHP image

Build custom Docker PHP images using Docker build arguments an shell scripts.

## Work in progress

As of now, it's only capable of building Alpine PHP cli images.  
PHP-FPM, PHP+Apache, PHP+Nginx will follow.

## Build your custom PHP images

In this example, we are building an **Alpine** PHP **7.1** **CLI** image with **xdebug** and **composer**:

```shell
make build DIST=alpine VARIANT=cli VERSION=7.1 ADDONS="xdebug composer"
```

It will result in a `[YOUR USERNAME]/php:7.1-cli-alpine` image

## PHP wrapper script

This project come with a wrapper script allowing you to use PHP inside Docker, you just have to source it.

`source ./docker-php.sh`

**Note: ** Documentation is missing right now, but it will come