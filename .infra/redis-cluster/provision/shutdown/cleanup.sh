#!/bin/bash
# Cleanup script for Redis Cluster
# This script performs cleanup when Redis Cluster is stopped

# On Linux and macOS, there's no port-forward setup to clean up
# The prepare.sh script doesn't configure port forwarding or firewall rules
# This script exists for consistency and can be extended in the future if needed
