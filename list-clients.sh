#!/bin/bash

# List all OAuth2 clients in Hydra
# Usage: ./list-clients.sh

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-http://localhost:4445}"

echo "Fetching OAuth2 clients..."
echo ""

curl -s "${HYDRA_ADMIN_URL}/admin/clients" | jq

echo ""
echo "To get details for a specific client:"
echo "curl ${HYDRA_ADMIN_URL}/admin/clients/{client_id} | jq"
