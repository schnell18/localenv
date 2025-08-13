#!/bin/bash
set -e

# Start CockroachDB in insecure mode for local development
cockroach start-single-node \
    --insecure \
    --listen-addr=0.0.0.0:26257 \
    --http-addr=0.0.0.0:8080 \
    --store=/cockroach/cockroach-data \
    --background

# Wait for CockroachDB to be ready
echo "Waiting for CockroachDB to start..."
until cockroach sql --insecure --host=localhost:26257 --execute="SELECT 1;" >/dev/null 2>&1; do
    printf '.'
    sleep 1
done
echo " CockroachDB is ready!"

# Keep the container running
tail -f /dev/null
