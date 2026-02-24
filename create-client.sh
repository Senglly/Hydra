#!/bin/bash

# Create an OAuth2 client in Hydra
# Usage: ./create-client.sh

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://localhost:4445}"

echo "Creating OAuth2 client..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${HYDRA_ADMIN_URL}/admin/clients" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "my-app",
    "client_name": "My Application",
    "client_secret": "my-super-secret-secret",
    "grant_types": [
      "authorization_code",
      "refresh_token"
    ],
    "response_types": [
      "code"
    ],
    "redirect_uris": [
      "https://gateway-production-6cac.up.railway.app/callback"
    ],
    "scope": "openid offline_access email profile",
    "token_endpoint_auth_method": "client_secret_post",
    "skip_consent": true
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
  echo ""
  echo "✓ Client created successfully!"
  echo ""
  echo "$BODY"
  echo ""
  echo "==================== CLIENT CREDENTIALS ===================="
  echo "Client ID:     my-app"
  echo "Client Secret: my-super-secret-secret"
  echo "==========================================================="
  echo ""
  echo "Test the OAuth2 flow:"
  echo "https://gateway-production-6cac.up.railway.app/oauth2/auth?client_id=my-app&response_type=code&scope=openid+email+profile&redirect_uri=https://gateway-production-6cac.up.railway.app/callback&state=random-state"
else
  echo ""
  echo "✗ Failed to create client (HTTP $HTTP_CODE)"
  echo "$BODY"
  exit 1
fi
