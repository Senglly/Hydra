#!/usr/bin/env bash
set -euo pipefail

# Recreate or update the IAM OAuth2 client in Hydra.
#
# Required env vars:
#   HYDRA_ADMIN_URL         e.g. https://hydra-production-xxxx.up.railway.app
#   OAUTH2_CLIENT_ID        must match iam-app env in production
#   OAUTH2_CLIENT_SECRET    must match iam-app env in production
#
# Optional env vars:
#   GATEWAY_URL             e.g. https://gateway-production-xxxx.up.railway.app
#                           used to build default redirect URI
#   OAUTH2_REDIRECT_URI     explicit callback URI (overrides GATEWAY_URL)
#   SKIP_CONSENT            true|false (default: true)

HYDRA_ADMIN_URL="${HYDRA_ADMIN_URL:-}"
OAUTH2_CLIENT_ID="${OAUTH2_CLIENT_ID:-}"
OAUTH2_CLIENT_SECRET="${OAUTH2_CLIENT_SECRET:-}"
GATEWAY_URL="${GATEWAY_URL:-}"
OAUTH2_REDIRECT_URI="${OAUTH2_REDIRECT_URI:-}"
SKIP_CONSENT="${SKIP_CONSENT:-true}"

if [[ -z "$HYDRA_ADMIN_URL" ]]; then
  echo "ERROR: HYDRA_ADMIN_URL is required." >&2
  exit 1
fi

if [[ -z "$OAUTH2_CLIENT_ID" ]]; then
  echo "ERROR: OAUTH2_CLIENT_ID is required." >&2
  exit 1
fi

if [[ -z "$OAUTH2_CLIENT_SECRET" ]]; then
  echo "ERROR: OAUTH2_CLIENT_SECRET is required." >&2
  exit 1
fi

if [[ -z "$OAUTH2_REDIRECT_URI" ]]; then
  if [[ -z "$GATEWAY_URL" ]]; then
    echo "ERROR: set OAUTH2_REDIRECT_URI or GATEWAY_URL." >&2
    exit 1
  fi
  OAUTH2_REDIRECT_URI="${GATEWAY_URL%/}/auth/callback"
fi

echo "Hydra Admin URL : ${HYDRA_ADMIN_URL}"
echo "Client ID       : ${OAUTH2_CLIENT_ID}"
echo "Redirect URI    : ${OAUTH2_REDIRECT_URI}"

read -r -d '' PAYLOAD <<JSON || true
{
  "client_id": "${OAUTH2_CLIENT_ID}",
  "client_name": "IAM Gateway",
  "client_secret": "${OAUTH2_CLIENT_SECRET}",
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "redirect_uris": ["${OAUTH2_REDIRECT_URI}"],
  "scope": "openid offline_access email profile",
  "token_endpoint_auth_method": "client_secret_post",
  "skip_consent": ${SKIP_CONSENT},
  "subject_type": "public"
}
JSON

status=$(curl -s -o /dev/null -w "%{http_code}" "${HYDRA_ADMIN_URL}/admin/clients/${OAUTH2_CLIENT_ID}")

if [[ "$status" == "200" ]]; then
  echo "Client exists. Updating..."
  curl -sSf -X PUT \
    "${HYDRA_ADMIN_URL}/admin/clients/${OAUTH2_CLIENT_ID}" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}" | python3 -m json.tool
else
  echo "Client missing. Creating..."
  curl -sSf -X POST \
    "${HYDRA_ADMIN_URL}/admin/clients" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}" | python3 -m json.tool
fi

echo "Verifying client..."
curl -sSf "${HYDRA_ADMIN_URL}/admin/clients/${OAUTH2_CLIENT_ID}" | python3 -m json.tool

echo "Done."