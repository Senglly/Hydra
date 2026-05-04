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

# Only delete signing keys when explicitly requested (e.g. after rotating SECRETS_SYSTEM)
# Deleting on every restart causes 503s while Hydra regenerates keys on first request
if [ "${FORCE_KEY_ROTATION}" = "true" ]; then
  echo "FORCE_KEY_ROTATION=true: clearing signing keys for regeneration..."
  psql "$DSN" -c "DELETE FROM hydra_jwk WHERE sid IN ('hydra.openid.id-token', 'hydra.jwt.access-token');" 2>&1 || echo "No keys to clear or already cleared"
else
  echo "Skipping key rotation (set FORCE_KEY_ROTATION=true to force)."
fi

echo "SECRETS_SYSTEM is set: ${SECRETS_SYSTEM:0:10}..."
echo "Starting Hydra server..."

# Start Hydra server
exec hydra serve all --config /tmp/hydra.yml