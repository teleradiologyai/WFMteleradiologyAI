#!/bin/bash

set -e

docker system prune -a -f

# Takes the PRODUCTION_ENV as argument
export PRODUCTION_ENV=$1

# Load the relevant env file for the PRODUCTION_ENV
if [ -f .env.docker-compose.$1 ]; then
    # Load Environment Variables
    export $(cat .env.docker-compose.$1 | grep -v '#' | awk '/=/ {print $1}')
fi

# Create a new docker compose file for the server.
cp ./docker-compose.template.yml ./docker-compose.server.yml

# Replace all the instances of env var placeholders in the new docker compose.
envsubst < "./docker-compose.template.yml" > "./docker-compose.server.yml"

# Restart all the docker containers.
docker-compose -f docker-compose.server.yml -p wfm --compatibility down
docker-compose -f docker-compose.server.yml -p wfm --compatibility build
docker-compose -f docker-compose.server.yml -p wfm --compatibility up -d
