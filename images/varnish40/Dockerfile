FROM debian:jessie
MAINTAINER Kaliop
LABEL varnish.version=4.0

ENV TERM xterm-color

ARG DOCKER_TIMEZONE=Europe/Paris

# Configure timezone
# -----------------------------------------------------------------------------
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# Base packages
# -----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    debian-archive-keyring \
    curl \
    vim \
    htop \
    procps \
    net-tools;

# varnish
# -----------------------------------------------------------------------------
RUN curl -L https://packagecloud.io/varnishcache/varnish40/gpgkey | apt-key add - && \
    echo "deb https://packagecloud.io/varnishcache/varnish40/debian/ wheezy main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    varnish varnish-agent;


COPY etc/default/varnish /etc/default/varnish
COPY etc/default/varnishncsa /etc/default/varnishncsa
# Fix user group for varnishncsa.pid
COPY etc/init.d/varnishncsa /etc/init.d/varnishncsa

RUN echo "varnish:CacheMeIfYouCan" > /etc/varnish/agent_secret

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

# Clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 81
EXPOSE 6082

CMD ["/root/bootstrap.sh"]
