FROM nextcloud:31.0.5-fpm-alpine

# Install OpenRC
RUN apk add --no-cache supervisor

# Create directories
RUN mkdir -p /opt/nextcloud-ai-worker /etc/supervisor/conf.d /var/log/supervisor /var/run

# Copy service script and make it executable
COPY scripts/nextcloud-ai-worker-taskprocessing.sh /opt/nextcloud-ai-worker/taskprocessing.sh
RUN chmod +x /opt/nextcloud-ai-worker/taskprocessing.sh

# Copy service descriptor and make it executable
COPY scripts/supervisor.conf /etc/supervisor/conf.d/nextcloud-ai-worker.conf

# Create entrypoint script
COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
