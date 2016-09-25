FROM debian:wheezy
MAINTAINER Kaliop
LABEL php.version=5.4

# Base packages
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    php5 \
    php5-cli \
	php5-mysqlnd \
	php5-mcrypt \
	php5-imagick \
	php5-curl \
	php5-xmlrpc \
	php5-gd \
	php5-json \
	php5-intl \
	php5-pgsql \
	php5-xsl \
	php5-memcached \
	php5-ldap \
	php5-xdebug \
	libapache2-mod-php5

# PHP config
# -----------------------------------------------------------------------------
# remove default xdebug config
RUN rm /etc/php5/apache2/conf.d/20-xdebug.ini

# -----------------------------------------------------------------------------

# Clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]