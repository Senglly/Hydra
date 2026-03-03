FROM oryd/hydra:v2.2.0

# Install envsubst and curl
USER root
RUN apk add --no-cache gettext curl postgresql-client

# Copy Hydra config
COPY hydra.yml /etc/config/hydra.yml

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Run entrypoint script
ENTRYPOINT ["sh", "/entrypoint.sh"]