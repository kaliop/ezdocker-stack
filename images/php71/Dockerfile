FROM debian:jessie
MAINTAINER Kaliop
LABEL php.version=7.1

# Base packages
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates wget

# Adding packages.sury.org repository for PHP 7
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ jessie main" > /etc/apt/sources.list.d/php.list


# PHP packages
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    php7.1 \
    php7.1-cli \
    php7.1-mysqlnd \
    php7.1-mcrypt \
    php7.1-imagick \
    php7.1-curl \
    php7.1-xmlrpc \
    php7.1-gd \
    php7.1-json \
    php7.1-intl \
    php7.1-pgsql \
    php7.1-xsl \
    php7.1-memcached \
    php7.1-ldap \
    php7.1-xdebug \
    php7.1-sqlite3

# PHP config
# -----------------------------------------------------------------------------
# Custom PHP-FPM error log folder
RUN mkdir /var/log/php/
RUN sed -rie 's|error_log = /var/log/php7.1-fpm.log|error_log = /var/log/php/php7.1-fpm.log|g' /etc/php/7.1/fpm/php-fpm.conf

# Disable xdebug
RUN echo -e "[xdebug] \nxdebug.default_enable=Off" >> /etc/php/7.1/cli/php.ini

# Clear archives in apt cache folder
#RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]