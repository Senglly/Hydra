#!/bin/sh
# Create MAS OAuth2 client in Hydra.
# Usage:
#   MAS_CLIENT_ID=mas-upstream MAS_REDIRECT_URI=https://mas.example.com/... ./create-mas-client.sh

set -eu

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://hydra.railway.internal:4445}"
MAS_CLIENT_ID="${MAS_CLIENT_ID:-mas-upstream}"
MAS_CLIENT_NAME="${MAS_CLIENT_NAME:-Matrix Authentication Service}"
MAS_CLIENT_SECRET="${MAS_CLIENT_SECRET:-$(openssl rand -hex 32)}"
MAS_REDIRECT_URI="${MAS_REDIRECT_URI:-}"

if [ -z "${MAS_REDIRECT_URI}" ]; then
  echo "ERROR: MAS_REDIRECT_URI is required."
  echo "Example: MAS_REDIRECT_URI=https://mas.example.com/upstream/callback/hydra ./create-mas-client.sh"
  exit 1
fi

echo "Creating MAS OAuth2 client in Hydra..."
echo "Hydra Admin: ${HYDRA_ADMIN_URL}"
echo "Client ID:   ${MAS_CLIENT_ID}"
echo "Redirect URI:${MAS_REDIRECT_URI}"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${HYDRA_ADMIN_URL}/admin/clients" \
  -H "Content-Type: application/json" \
  -d "{
    \"client_id\": \"${MAS_CLIENT_ID}\",
    \"client_name\": \"${MAS_CLIENT_NAME}\",
    \"client_secret\": \"${MAS_CLIENT_SECRET}\",
    \"grant_types\": [\"authorization_code\", \"refresh_token\"],
    \"response_types\": [\"code\"],
    \"redirect_uris\": [\"${MAS_REDIRECT_URI}\"],
    \"scope\": \"openid offline_access email profile\",
    \"token_endpoint_auth_method\": \"client_secret_post\",
    \"skip_consent\": true
  }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
  echo ""
  echo "MAS client created successfully"
  echo ""
  echo "$BODY"
  echo ""
  echo "==================== MAS CLIENT CREDENTIALS ===================="
  echo "MAS_HYDRA_CLIENT_ID=${MAS_CLIENT_ID}"
  echo "MAS_HYDRA_CLIENT_SECRET=${MAS_CLIENT_SECRET}"
  echo "MAS_HYDRA_ISSUER=<your-hydra-public-issuer-url>"
  echo "==============================================================="
else
  echo ""
  echo "Failed to create MAS client (HTTP $HTTP_CODE)"
  echo "$BODY"
  exit 1
fi
