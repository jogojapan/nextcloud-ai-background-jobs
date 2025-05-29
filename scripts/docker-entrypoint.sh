#!/bin/sh

# Copy mounted script
if [ -f /mnt/taskprocessing.sh ]; then
    cp /mnt/taskprocessing.sh /opt/nextcloud-ai-worker/taskprocessing.sh
    chmod +x /opt/nextcloud-ai-worker/taskprocessing.sh
fi

# Copy mounted service descriptor
if [ -f /mnt/supervisor.conf ]; then
    cp /mnt/supervisor.conf /etc/supervisor/conf.d/nextcloud-ai-worker.conf
fi

# Verify script exists
if [ ! -x /opt/nextcloud-ai-worker/taskprocessing.sh ]; then
    echo "ERROR: Script is not executable"
    exit 1
fi

# Start supervisor
echo "Starting supervisord..."
exec supervisord -c /etc/supervisor/conf.d/nextcloud-ai-worker.conf
