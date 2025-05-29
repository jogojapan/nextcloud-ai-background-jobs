#!/bin/sh
echo "Starting Nextcloud AI Worker $1"
/var/www/html/occ background-job:worker -t 120 'OC\TaskProcessing\SynchronousBackgroundJob'
