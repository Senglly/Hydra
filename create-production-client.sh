#!/bin/sh
# Create OAuth2 client in production Hydra
# Run this from Railway using: railway run --service Hydra bash create-production-client.sh

HYDRA_ADMIN_URL="http://localhost:4445"
GATEWAY_URL="https://gateway-production-6cac.up.railway.app"

echo "Creating OAuth2 client for production..."
echo "Gateway URL: $GATEWAY_URL"
echo "Hydra Admin: $HYDRA_ADMIN_URL"
echo ""

RESPONSE=$(curl -s -X POST "${HYDRA_ADMIN_URL}/admin/clients" \
  -H "Content-Type: application/json" \
  -d "{
    \"client_name\": \"iam-app-production\",
    \"grant_types\": [\"authorization_code\", \"refresh_token\"],
    \"response_types\": [\"code\"],
    \"redirect_uris\": [\"${GATEWAY_URL}/auth/callback\"],
    \"scope\": \"openid offline_access email profile\",
    \"token_endpoint_auth_method\": \"client_secret_post\",
    \"skip_consent\": true
  }")

echo "=========================================="
echo "FULL RESPONSE:"
echo "=========================================="
echo "$RESPONSE"
echo ""
echo ""
echo "=========================================="
echo "Extract CLIENT_ID and CLIENT_SECRET from above"
echo "=========================================="
