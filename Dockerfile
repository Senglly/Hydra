FROM oryd/hydra:v2.2.0

# Copy Hydra config
COPY hydra.yml /etc/config/hydra.yml

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Run entrypoint script
ENTRYPOINT ["/entrypoint.sh"]