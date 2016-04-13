FROM ubuntu:14.04
MAINTAINER Kaliop
LABEL memcached.version=1.4

ARG DOCKER_TIMEZONE=Europe/Paris

# Configure timezone
# -----------------------------------------------------------------------------
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

ENV MEMCACHED_USER=nobody

# Base packages
# -----------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    memcached

RUN rm /etc/memcached.conf
COPY memcached.conf /etc/memcached.conf
# q: why do we alter a file we just copied ??? This is probably only necessary if using the stock conf...
RUN chmod 644 /etc/memcached.conf \
    && sed 's/^-d/# -d/' -i /etc/memcached.conf

# Clear archives in apt cache folder
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 11211/tcp 11211/udp

CMD ["/root/bootstrap.sh"]
