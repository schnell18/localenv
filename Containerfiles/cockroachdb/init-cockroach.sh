#!/bin/bash
set -e

# This script runs during container initialization
# Additional setup can be added here if needed

# Create localenv user and database
echo "Creating localenv user and database..."
cockroach sql --insecure --host=localhost:26257 <<EOF
CREATE USER IF NOT EXISTS localenv;
CREATE DATABASE IF NOT EXISTS localenv;
GRANT ALL ON DATABASE localenv TO localenv;
GRANT admin TO localenv;
EOF

# Create a simple user authentication mechanism for the web UI
# Note: CockroachDB doesn't have built-in password authentication in insecure mode
# but we'll set up the user for consistency with other services
echo "User 'localenv' created with admin privileges"
echo "Database 'localenv' created and accessible"
echo "Web UI available at http://localhost:8080"

