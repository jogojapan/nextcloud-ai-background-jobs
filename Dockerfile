FROM nextcloud:31.0.5-fpm-alpine

# Install OpenRC
RUN apk add --no-cache supervisor

# Create directories
RUN mkdir -p /opt/nextcloud-ai-worker \
             /etc/supervisor/conf.d \
             /var/log/supervisor \
             /var/run \
    && chown -R www-data:www-data /opt/nextcloud-ai-worker

# Copy service script and make it executable
COPY scripts/nextcloud-ai-worker-taskprocessing.sh /opt/nextcloud-ai-worker/taskprocessing.sh
RUN chmod +x /opt/nextcloud-ai-worker/taskprocessing.sh

# Copy service descriptor
COPY scripts/supervisor.conf /etc/supervisor/conf.d/nextcloud-ai-worker.conf

# Copy healthcheck script
COPY scripts/healthcheck.sh /opt/nextcloud-ai-worker/healthcheck.sh
RUN chmod +x /opt/nextcloud-ai-worker/healthcheck.sh

# Create entrypoint script
COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Environment variables
ENV WORKER_INSTANCE=1
ENV RESTART_PERIOD_SEC=120

ENTRYPOINT ["/docker-entrypoint.sh"]

# Health check
HEALTHCHECK --interval=300s --timeout=10s --start-period=10s --retries=2 \
    CMD ["/bin/sh", "/opt/nextcloud-ai-worker/healthcheck.sh"]
