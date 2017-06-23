FROM klabs/php71
MAINTAINER Kaliop
LABEL nginx.version=1.2 \
      php.version=7.1 \
      application.type=PHP

ARG DOCKER_TIMEZONE=Europe/Paris
ARG DOCKER_LOCALE=fr_FR.UTF-8

# Configure timezone
# -----------------------------------------------------------------------------
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# Base packages
# Java (used for eg. eZTika indexing)
# poppler-utils used for pdftotext binary (note that eztika is a much better option!)
# -----------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    pwgen \
    sudo \
    nano \
    unzip \
    locales \
    imagemagick \
    jpegoptim \
    poppler-utils \
    openjdk-7-jre-headless;

# locale for date, time & currency php functions
# -----------------------------------------------------------------------------
RUN dpkg-reconfigure locales && \
    echo $DOCKER_LOCALE' UTF-8'>> /etc/locale.gen && \
    locale-gen $DOCKER_LOCALE && \
    /usr/sbin/update-locale LANG=$DOCKER_LOCALE

ENV LC_ALL $DOCKER_LOCALE
ENV LANG $DOCKER_LOCALE
ENV LANGUAGE $DOCKER_LOCALE

# Install Nginx & PHP
# -----------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx \
    php7.1-fpm

# Local user
# => to try : run container with --user option to set root user id with host user id
# -----------------------------------------------------------------------------
# nb: the 1013 used here for user id and group id is later on replaced by the code in bootstrap.sh...
RUN addgroup --gid 1013 site && \
    adduser --system --uid=1013 --gid=1013 \
        --home /home/site --shell /bin/bash site && \
    adduser site site && \
    adduser site www-data && \
    mkdir -p /home/site/.ssh; \
    cp /etc/skel/.* /home/site/; \
    chown -R site:site /home/site;

# Nginx config
# -----------------------------------------------------------------------------
RUN sed -i -e"s/worker_processes  1/worker_processes 4/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
sed -i -e's|user www-data;|user site;|g' /etc/nginx/nginx.conf

RUN chmod 755 -R /var/log/nginx

# PHP config
# -----------------------------------------------------------------------------
RUN sed -rie 's|user = www-data|user = site|g' /etc/php/7.1/fpm/pool.d/www.conf && \
    sed -rie 's|listen.owner = www-data|listen.owner = site|g' /etc/php/7.1/fpm/pool.d/www.conf

# Disable xdebug
RUN rm /etc/php/7.1/fpm/conf.d/20-xdebug.ini

# Custom PHP-FPM error log folder
RUN mkdir /var/log/php/
RUN chmod 755 -R /var/log/php/
RUN sed -rie 's|error_log = /var/log/php7.1-fpm.log|error_log = /var/log/php/php7.1-fpm.log|g' /etc/php/7.1/fpm/php-fpm.conf


# Vhost config
# -----------------------------------------------------------------------------
# controlpanel is burned into the container
COPY etc/nginx/conf.d/010-controlpanel.conf /etc/nginx/conf.d/010-controlpanel.conf
COPY etc/nginx/sites-available/default /etc/nginx/sites-available/000-default
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/000-default /etc/nginx/sites-enabled/000-default

COPY sites/controlpanel/ /home/site/controlpanel/

# Run composer install for phpmemadmin vendors
RUN cd /home/site/controlpanel/phpmemadmin && \
    curl -sS https://getcomposer.org/installer | php -- && \
    php composer.phar install --no-dev --ignore-platform-reqs

# -----------------------------------------------------------------------------

# Clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 443
EXPOSE 80
EXPOSE 82

WORKDIR /var/www/

CMD ["/root/bootstrap.sh"]
