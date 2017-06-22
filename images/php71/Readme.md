# PHP 7.1 Base Docker image

This is the base PHP image used as parent image for apache & cli images, built from Debian Jessie.

PHP 7.1 is installed with support for FPM.

This image should be used as Base image in Dockerfiles needing php.

Example from Apache_php7 Dockerfile: 


    FROM klabs/php71
    LABEL apache.version=2.4