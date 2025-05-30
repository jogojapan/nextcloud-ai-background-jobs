#!/bin/sh
echo "Starting Nextcloud AI Worker $1"
/var/www/html/occ background-job:worker -t $(RESTART_PERIOD_SEC) 'OC\TaskProcessing\SynchronousBackgroundJob'

# Debugging
# sleep 5 ; /usr/bin/supervisorctl -u supervisor -p supervisor status nextcloud-ai-worker &> /tmp/simul_healthcheck.log
