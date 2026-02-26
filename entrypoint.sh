#!/bin/sh
set -e

echo "Starting Hydra..."

# Ensure required environment variables are set
if [ -z "$DSN" ]; then
  echo "ERROR: DSN environment variable is not set!"
  exit 1
fi

if [ -z "$SECRETS_SYSTEM" ]; then
  echo "ERROR: SECRETS_SYSTEM is not set!"
  exit 1
fi

if [ -z "$URLS_SELF_ISSUER" ]; then
  echo "ERROR: URLS_SELF_ISSUER is not set!"
  exit 1
fi

if [ -z "$URLS_LOGIN" ]; then
  echo "ERROR: URLS_LOGIN is not set!"
  exit 1
fi

# Expand environment variables in the config file
echo "Expanding environment variables in config..."
envsubst < /etc/config/hydra.yml > /tmp/hydra.yml

# Debug: Show the expanded config (optional)
echo "=== Expanded Config ==="
cat /tmp/hydra.yml
echo "======================="

# Run migrations
echo "Running database migrations..."
hydra migrate sql "$DSN" --yes

# Start Hydra server with expanded config
echo "Starting Hydra server..."
exec hydra serve all --config /tmp/hydra.yml