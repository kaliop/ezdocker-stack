FROM debian:jessie
MAINTAINER Kaliop
LABEL solr.version=4.10

ENV DEBIAN_FRONTEND noninteractive

ARG DOCKER_TIMEZONE=Europe/Paris

# Configure timezone
# -----------------------------------------------------------------------------
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# Base packages
# -----------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qqy \
    openjdk-7-jre-headless

COPY ./solr_4.10 /opt/solr
COPY init/solr /etc/init.d/solr
RUN chmod 755 /etc/init.d/solr

# -----------------------------------------------------------------------------

# Clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 8983

WORKDIR /opt/solr

CMD ["/root/bootstrap.sh"]