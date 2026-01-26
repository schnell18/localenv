#!/bin/bash

basedir=$(pwd)
state_dir="${basedir}/.state/nats"

# Create state directories for NATS data persistence
if [[ ! -d "${state_dir}/data" ]]; then
    echo "Creating NATS data directory..."
    mkdir -p "${state_dir}/data"
fi

if [[ ! -d "${state_dir}/nui-db" ]]; then
    echo "Creating NUI database directory..."
    mkdir -p "${state_dir}/nui-db"
fi

if [[ ! -d "${state_dir}/nui-contexts" ]]; then
    echo "Creating NUI contexts directory..."
    cp -r ${basedir}/.infra/nats/provision/contexts/ ${state_dir}/nui-contexts
fi
echo "NATS preparation completed."
