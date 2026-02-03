#!/bin/sh
set -e

# Debug: Print environment variables (remove in production)
echo "Starting Hydra..."
echo "DSN is set: $([ -n "$DSN" ] && echo 'yes' || echo 'no')"
echo "RAILWAY_PUBLIC_DOMAIN: ${RAILWAY_PUBLIC_DOMAIN}"

# Ensure DSN is set
if [ -z "$DSN" ]; then
  echo "ERROR: DSN environment variable is not set!"
  exit 1
fi

# Validate DSN format
echo "DSN format: ${DSN%%:*}" # Shows only the scheme part

# Run migrations first
echo "Running database migrations..."
hydra migrate sql --yes --config /etc/config/hydra.yml

# Start Hydra server
echo "Starting Hydra server..."
exec hydra serve all --config /etc/config/hydra.yml