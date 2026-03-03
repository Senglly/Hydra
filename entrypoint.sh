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

# Start Hydra in background
echo "Starting Hydra server..."
hydra serve all --config /tmp/hydra.yml &
HYDRA_PID=$!

# Wait for Hydra admin API to be ready
echo "Waiting for Hydra admin API..."
sleep 15

# Create signing keys via admin API
echo "Creating ID token signing key..."
curl -v -X POST http://localhost:4445/admin/keys/hydra.openid.id-token \
  -H "Content-Type: application/json" \
  -d '{
    "alg": "RS256",
    "use": "sig"
  }' 2>&1 | head -30

echo "Creating access token signing key..."
curl -v -X POST http://localhost:4445/admin/keys/hydra.jwt.access-token \
  -H "Content-Type: application/json" \
  -d '{
    "alg": "RS256",
    "use": "sig"
  }' 2>&1 | head -30

echo "Keys created, Hydra running in foreground..."
# Bring Hydra back to foreground
wait $HYDRA_PID