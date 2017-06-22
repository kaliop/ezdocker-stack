FROM klabs/php56
MAINTAINER Kaliop
LABEL apache.version=2.4 \
      php.version=5.6 \
      application.type=ezpublish

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
    locales \
    imagemagick \
    jpegoptim \
    poppler-utils \
    openjdk-7-jre-headless;

# locale for date, time & currency php functions
# q: for what is the locale setup needed ?
# -----------------------------------------------------------------------------
RUN dpkg-reconfigure locales && \
    echo $DOCKER_LOCALE' UTF-8'>> /etc/locale.gen && \
    locale-gen $DOCKER_LOCALE && \
    /usr/sbin/update-locale LANG=$DOCKER_LOCALE

ENV LC_ALL $DOCKER_LOCALE
ENV LANG $DOCKER_LOCALE
ENV LANGUAGE $DOCKER_LOCALE

# Apache
# -----------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

# Local user
# @todo simplify this as much as possible, or plain remove
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

# Apache config
# -----------------------------------------------------------------------------
ENV APACHE_RUN_USER site
ENV APACHE_RUN_GROUP site
ENV APACHE_LOG_DIR /var/log/apache2/sites
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR  /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN sed -rie 's|export APACHE_RUN_USER=.*|export APACHE_RUN_USER=site|g' /etc/apache2/envvars
RUN sed -rie 's|export APACHE_RUN_GROUP=.*|export APACHE_RUN_GROUP=site|g' /etc/apache2/envvars
RUN sed -rie 's|export APACHE_LOG_DIR=.*|export APACHE_LOG_DIR=/var/log/apache2|g' /etc/apache2/envvars

RUN rm /etc/apache2/ports.conf
COPY apache2/ports.conf /etc/apache2/ports.conf

#RUN printf "\n# Fix for Vagrant - Do not use this on production!\nEnableSendfile Off\n" >> /etc/apache2/apache2.conf

RUN a2enmod rewrite headers vhost_alias proxy_http proxy ssl info status

# vhost config
# controlpanel is burned into the container, while the sites-enabled dir is mounted as volume
COPY apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache2/010-controlpanel.conf /tmp/010-controlpanel.conf
RUN cat /tmp/010-controlpanel.conf >> /etc/apache2/apache2.conf
RUN rm /tmp/010-controlpanel.conf

RUN a2ensite 000-default.conf

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
