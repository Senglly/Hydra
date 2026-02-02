FROM oryd/hydra:v2.2.0

# Copy Hydra config
COPY hydra.yml /etc/config/hydra.yml

# Copy entrypoint script (already executable)
COPY entrypoint.sh /entrypoint.sh

# Run entrypoint via /bin/sh -c
ENTRYPOINT ["/bin/sh", "-c", "/entrypoint.sh"]
