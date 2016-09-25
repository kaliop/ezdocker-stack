# PHP 5.4 Base Docker image

This is the base PHP image used as parent image for apache & cli images, built from Debian Jessie

This image should be used as Base image in Dockerfiles needing php.

Example from Apache Dockerfile: 


    FROM klabs/php54
    LABEL apache.version=2.4