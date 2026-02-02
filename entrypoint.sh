#!/bin/sh

# Ensure DSN is set
if [ -z "$DSN" ]; then
  echo "DSN environment variable is not set!"
  exit 1
fi

# Run migrations first
hydra migrate sql --yes --config /etc/config/hydra.yml

# Start Hydra server
hydra serve all --config /etc/config/hydra.yml
