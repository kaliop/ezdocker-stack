FROM docker.elastic.co/beats/filebeat:5.4.2
USER root
COPY service.sh /root/service.sh
RUN chmod +x /root/service.sh && mkdir /usr/share/filebeat/conf.d/
WORKDIR /usr/share/filebeat/
CMD ["/root/service.sh"]
