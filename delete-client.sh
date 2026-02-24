#!/bin/bash

# Delete an OAuth2 client from Hydra
# Usage: ./delete-client.sh <client_id>

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://localhost:4445}"
CLIENT_ID="${1}"

if [ -z "$CLIENT_ID" ]; then
  echo "Usage: ./delete-client.sh <client_id>"
  echo "Example: ./delete-client.sh my-app"
  exit 1
fi

echo "Deleting client: $CLIENT_ID"
echo ""

curl -X DELETE "${HYDRA_ADMIN_URL}/admin/clients/${CLIENT_ID}"

echo ""
echo "Client deleted successfully!"
