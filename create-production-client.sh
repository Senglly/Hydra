#!/bin/sh
# Create OAuth2 IAM client in Hydra.
# Run inside Railway Hydra service:
# railway run --service Hydra sh create-production-client.sh

set -eu

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://localhost:4445}"
GATEWAY_URL="${GATEWAY_URL:-https://gateway-sengly-branch.up.railway.app}"
CLIENT_ID="${CLIENT_ID:-iam-client}"
CLIENT_NAME="${CLIENT_NAME:-iam-app-production}"
CLIENT_SECRET="${CLIENT_SECRET:-$(openssl rand -hex 32)}"

echo "Creating OAuth2 IAM client..."
echo "Hydra Admin: ${HYDRA_ADMIN_URL}"
echo "Gateway URL: ${GATEWAY_URL}"
echo "Client ID:   ${CLIENT_ID}"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${HYDRA_ADMIN_URL}/admin/clients" \
  -H "Content-Type: application/json" \
  -d "{
    \"client_id\": \"${CLIENT_ID}\",
    \"client_name\": \"${CLIENT_NAME}\",
    \"client_secret\": \"${CLIENT_SECRET}\",
    \"grant_types\": [\"authorization_code\", \"refresh_token\"],
    \"response_types\": [\"code\"],
    \"redirect_uris\": [\"${GATEWAY_URL}/auth/callback\"],
    \"scope\": \"openid offline_access email profile\",
    \"token_endpoint_auth_method\": \"client_secret_post\",
    \"skip_consent\": true
  }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
  echo ""
  echo "Client created successfully"
  echo ""
  echo "${BODY}"
  echo ""
  echo "=========================================="
  echo "Set these in iam-app environment"
  echo "=========================================="
  echo "OAUTH2_CLIENT_ID=${CLIENT_ID}"
  echo "OAUTH2_CLIENT_SECRET=${CLIENT_SECRET}"
  echo ""
  echo "Auth URL test"
  echo "${GATEWAY_URL}/oauth2/auth?client_id=${CLIENT_ID}&response_type=code&scope=openid+email+profile+offline_access&redirect_uri=${GATEWAY_URL}/auth/callback&state=iam-login"
else
  echo ""
  echo "Failed to create client (HTTP ${HTTP_CODE})"
  echo "${BODY}"
  exit 1
fi
