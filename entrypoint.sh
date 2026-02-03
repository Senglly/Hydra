#!/bin/sh
set -e

# Debug info
echo "Starting Hydra..."
echo "DSN is set: $([ -n "$DSN" ] && echo 'yes' || echo 'no')"
echo "RAILWAY_PUBLIC_DOMAIN: ${RAILWAY_PUBLIC_DOMAIN}"

# Ensure DSN is set
if [ -z "$DSN" ]; then
  echo "ERROR: DSN environment variable is not set!"
  exit 1
fi

# Run migrations - DSN as positional argument
echo "Running database migrations..."
hydra migrate sql "$DSN" --yes

# Start Hydra server - config file will read ${DSN} from environment
echo "Starting Hydra server..."
exec hydra serve all --config /etc/config/hydra.yml