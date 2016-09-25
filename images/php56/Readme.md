# PHP 5.6 Base Docker image

This is the base PHP image used as parent image for apache & cli images, built from Debian Lenny

This image should be used as Base image in Dockerfiles needing php.

Example from Apache Dockerfile: 


    FROM klabs/php56
    LABEL apache.version=2.4