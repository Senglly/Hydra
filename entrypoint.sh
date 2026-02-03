#!/bin/sh
set -e

# Debug info
echo "Starting Hydra..."
echo "DSN is set: $([ -n "$DSN" ] && echo 'yes' || echo 'no')"
echo "RAILWAY_PUBLIC_DOMAIN: ${RAILWAY_PUBLIC_DOMAIN}"
echo "DSN format: ${DSN%%:*}"

# Ensure DSN is set
if [ -z "$DSN" ]; then
  echo "ERROR: DSN environment variable is not set!"
  exit 1
fi

# Run migrations with explicit --dsn flag
echo "Running database migrations..."
hydra migrate sql --dsn "$DSN" --yes

# Start Hydra server with explicit --dsn flag
echo "Starting Hydra server..."
exec hydra serve all --dsn "$DSN" --config /etc/config/hydra.yml