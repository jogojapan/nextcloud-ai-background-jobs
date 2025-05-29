#!/bin/sh

MAX_ATTEMPTS=3
SLEEP_TIME=3

for attempt in $(seq 1 $MAX_ATTEMPTS); do
  if /usr/bin/supervisorctl -u supervisor -p supervisor status nextcloud-ai-worker | /bin/grep -q RUNNING; then
    exit 0
  fi
  if [ $attempt -lt $MAX_ATTEMPTS ]; then
    sleep $SLEEP_TIME
  fi
done

exit 1
