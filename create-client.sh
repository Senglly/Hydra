#!/bin/bash

# Create an OAuth2 IAM client in Hydra
# Usage:
#   CLIENT_ID=iam-client GATEWAY_URL=https://gateway.example.com ./create-client.sh

set -euo pipefail

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://hydra.railway.internal:4445}"
GATEWAY_URL="${GATEWAY_URL:-https://gateway-sengly-branch.up.railway.app}"
CLIENT_ID="${CLIENT_ID:-iam-client}"
CLIENT_NAME="${CLIENT_NAME:-IAM Application}"
CLIENT_SECRET="${CLIENT_SECRET:-$(openssl rand -hex 32)}"

echo "Creating OAuth2 IAM client..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${HYDRA_ADMIN_URL}/admin/clients" \
  -H "Content-Type: application/json" \
  -d "{
    \"client_id\": \"${CLIENT_ID}\",
    \"client_name\": \"${CLIENT_NAME}\",
    \"client_secret\": \"${CLIENT_SECRET}\",
    \"grant_types\": [
      \"authorization_code\",
      \"refresh_token\"
    ],
    \"response_types\": [
      \"code\"
    ],
    \"redirect_uris\": [
      \"${GATEWAY_URL}/auth/callback\"
    ],
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
  echo "$BODY"
  echo ""
  echo "==================== CLIENT CREDENTIALS ===================="
  echo "Client ID:     ${CLIENT_ID}"
  echo "Client Secret: ${CLIENT_SECRET}"
  echo "==========================================================="
  echo ""
  echo "Set these in iam-app environment:"
  echo "OAUTH2_CLIENT_ID=${CLIENT_ID}"
  echo "OAUTH2_CLIENT_SECRET=${CLIENT_SECRET}"
  echo ""
  echo "Test the OAuth2 flow:"
  echo "${GATEWAY_URL}/oauth2/auth?client_id=${CLIENT_ID}&response_type=code&scope=openid+email+profile+offline_access&redirect_uri=${GATEWAY_URL}/auth/callback&state=iam-login"
else
  echo ""
  echo "Failed to create client (HTTP $HTTP_CODE)"
  echo "$BODY"
  exit 1
fi
