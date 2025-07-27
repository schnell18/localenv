#!/bin/bash

database=$1
user=$2

echo "Creating database $database for user $user..."

# Connect as superuser and create database and user
PGPASSWORD=localenv psql -h localhost -U localenv -d postgres <<EOF
-- Create user if not exists
DO
\$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles 
      WHERE rolname = '$user') THEN
      CREATE USER $user WITH PASSWORD '$user';
   END IF;
END
\$\$;

-- Create database if not exists
SELECT 'CREATE DATABASE $database OWNER $user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$database')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
EOF

echo "Database $database created successfully for user $user"