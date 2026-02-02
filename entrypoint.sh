#!/bin/sh
# entrypoint.sh

# Run migrations first
hydra migrate sql --yes --config /etc/config/hydra.yml

# Then start the Hydra server
hydra serve all --config /etc/config/hydra.yml
