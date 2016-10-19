FROM mysql:5.6
MAINTAINER Kaliop
LABEL mysql.version=5.6

ARG DOCKER_TIMEZONE=Europe/Paris

# Configure timezone
# -----------------------------------------------------------------------------
RUN echo $DOCKER_TIMEZONE > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# Make the entrypoint a bit more friendly to debugging: keep it alive even if mysql fails starting
# NB: the container will still fail and suicide if there is an error in the part of entrypoint.sh which deals with
# creation of the db
#RUN sed -i 's/exec "$@"/\/etc\/init.d\/mysql start/g' /entrypoint.sh
#RUN echo 'tail -f /dev/null' >> /entrypoint.sh

COPY bootstrap.sh /root/bootstrap.sh
RUN chmod 755 /root/bootstrap.sh

EXPOSE 3306

ENTRYPOINT []
CMD ["/root/bootstrap.sh", "mysqld"]
