FROM oryd/hydra:v2.2.0

# Copy Hydra config
COPY hydra.yml /etc/config/hydra.yml

# Run migrations first
ENTRYPOINT ["hydra", "migrate", "sql", "--yes", "--config", "/etc/config/hydra.yml"]

# Start Hydra server after migrations
CMD ["serve", "all", "--config", "/etc/config/hydra.yml"]
