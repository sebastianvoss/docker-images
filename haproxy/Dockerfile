FROM debian:latest
MAINTAINER Sebastian Voss <docker@dev24.de>

# install haproxy and rsyslog
RUN apt-get update && apt-get install -y \
    haproxy \
    rsyslog \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# configure rsyslog
RUN printf '\n%s\n%s\n%s\n' \
    '$ModLoad imudp' \
    '$UDPServerRun 514' \
    '$UDPServerAddress 127.0.0.1' \ 
 >> /etc/rsyslog.conf

# copy haproxy start script
COPY start_haproxy.sh /start_haproxy.sh

# copy rsyslog rules file for rsyslog
COPY rsyslog_haproxy.conf /etc/rsyslog.d/haproxy.conf

VOLUME ["/haproxy-override"]

EXPOSE 5000 9000

CMD ["/start_haproxy.sh"]
