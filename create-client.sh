#!/bin/bash

# Create an OAuth2 client in Hydra
# Usage: ./create-client.sh

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://localhost:4445}"

curl -X POST "${HYDRA_ADMIN_URL}/admin/clients" \
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
      "http://localhost:3000/callback",
      "https://your-app.com/callback"
    ],
    "scope": "openid offline_access email profile",
    "token_endpoint_auth_method": "client_secret_post",
    "skip_consent": false
  }' | jq

echo ""
echo "Client created successfully!"
echo ""
echo "To test the OAuth2 flow, visit:"
echo "https://hydra-production-a56f.up.railway.app/oauth2/auth?client_id=my-app&response_type=code&scope=openid+email+profile&redirect_uri=http://localhost:3000/callback&state=random-state"
