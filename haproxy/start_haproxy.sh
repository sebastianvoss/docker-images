#!/usr/bin/env bash

HAPROXY="/etc/haproxy"
OVERRIDE="/haproxy-override"

CONFIG="haproxy.cfg"
ERRORS="errors"

HAPROXY_PID="/var/run/haproxy.pid"
SYSLOG_PID="/var/run/syslog.pid"

LOGS="/var/log"

function finish {
  # stop haproxy
  kill `cat $HAPROXY_PID`
  # stop syslog
  kill `cat $SYSLOG_PID`
  # archive haproxy logs
  mv $LOGS/haproxy.log $LOGS/haproxy_$(date +"%Y%m%d_%H%M%S").log
  # stop tailing the haproxy log file
  kill $PID1
}

# register function finish to fire on SIGTERM (sent by 'docker stop')
trap finish SIGTERM

cd "$HAPROXY"

# symlink errors directory
if [[ -d "$OVERRIDE/$ERRORS" ]]; then
  mkdir -p "$OVERRIDE/$ERRORS"
  rm -fr "$ERRORS"
  ln -s "$OVERRIDE/$ERRORS" "$ERRORS"
fi

# symlink config file.
if [[ -f "$OVERRIDE/$CONFIG" ]]; then
  rm -f "$CONFIG"
  ln -s "$OVERRIDE/$CONFIG" "$CONFIG"
fi

# start syslog
rsyslogd -i $SYSLOG_PID

# start haproxy
haproxy -f $HAPROXY/$CONFIG -p $HAPROXY_PID

# tail haproxy log file and store the pid (this will keep the container running and make logs available for 'docker logs')
tail -F $LOGS/haproxy.log &
PID1=$!

# wait till tail stops
wait $PID1

