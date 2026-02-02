FROM oryd/hydra:v2.2.0

# Copy Hydra config
COPY hydra.yml /etc/config/hydra.yml

# Copy entrypoint script (no chmod needed)
COPY entrypoint.sh /entrypoint.sh

# Run entrypoint script explicitly with sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
