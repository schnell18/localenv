#!/bin/bash
set -e

# This script runs during container initialization
# Create additional users and databases as needed

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create additional extensions
    CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
    CREATE EXTENSION IF NOT EXISTS uuid-ossp;

    -- Grant localenv user superuser privileges for development
    ALTER USER localenv CREATEDB CREATEROLE;

    -- Create additional development databases
    CREATE DATABASE devdb OWNER localenv;
    CREATE DATABASE testdb OWNER localenv;
EOSQL

echo "PostgreSQL initialization completed"
