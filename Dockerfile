FROM oryd/hydra:v2.2.0

# Install envsubst (part of gettext package)
USER root
RUN apk add --no-cache gettext

# Copy Hydra config
COPY hydra.yml /etc/config/hydra.yml

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Switch back to hydra user for security
USER hydra

# Run entrypoint script
ENTRYPOINT ["sh", "/entrypoint.sh"]