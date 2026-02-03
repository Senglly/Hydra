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

# Run migrations - DSN as positional argument
echo "Running database migrations..."
hydra migrate sql "$DSN" --yes

# Start Hydra server - use -e flag to read DSN from environment
echo "Starting Hydra server..."
exec hydra serve all -e --config /etc/config/hydra.yml