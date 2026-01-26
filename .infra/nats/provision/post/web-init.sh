#!/bin/bash

curl -s -XPOST \
    -H "Content-Type: application/json" \
    http://localhost:31311/api/connection/import/nats-cli \
    -d'{"path": "/contexts"}' > /dev/null
