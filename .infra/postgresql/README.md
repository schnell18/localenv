# PostgreSQL Infrastructure

This directory contains the PostgreSQL infrastructure configuration for the localenv project.

## Overview

This infrastructure provides:
- PostgreSQL 17 database server (Alpine Linux based)
- pgAdmin 4 web-based administration interface
- Cross-platform support (Linux, macOS, Windows)
- Pre-configured with localenv conventions

## Quick Start

### Start PostgreSQL
```bash
./infractl.sh start postgresql
```

This will:
1. Start PostgreSQL server on port 5432
2. Start pgAdmin web interface on port 5050
3. Automatically open pgAdmin in your browser

### Stop PostgreSQL
```bash
./infractl.sh stop postgresql
```

### Access Web UI
```bash
./infractl.sh webui postgresql
```
Opens pgAdmin at http://127.0.0.1:5050/

## Configuration

### Default Credentials
- **PostgreSQL Admin**: `localenv` / `localenv`
- **pgAdmin Web Interface**: `admin@localenv.org` / `localenv`

### Default Databases
The following databases are created automatically:
- `localenv` (default database)
- `devdb` (development database)
- `testdb` (testing database)

### Ports
- **PostgreSQL Server**: 5432
- **pgAdmin Web Interface**: 5050

## pgAdmin Configuration

The PostgreSQL server is pre-configured in pgAdmin with the following settings:
- **Server Name**: LocalEnv PostgreSQL
- **Host**: postgresql (container name)
- **Port**: 5432
- **Database**: localenv
- **Username**: localenv

## Data Persistence

Data is stored in the following directories:
- **PostgreSQL Data**: `.state/postgresql/data/`
- **PostgreSQL Config**: `.state/postgresql/conf/`
- **pgAdmin Data**: `.state/postgresql/pgadmin/`

## Database Management

### Create a New Database
```bash
# From within the PostgreSQL container
./infractl.sh attach postgresql
psql -U localenv -d postgres -c "CREATE DATABASE myapp OWNER localenv;"

# Or using the provided script
podman exec -it postgresql_postgresql_1 /setup/create-database.sh myapp myuser
```

### Load Schema and Data
```bash
podman exec -it postgresql_postgresql_1 /setup/load-schema-and-data.sh myapp myuser schema.sql data.sql
```

## Configuration Files

- **PostgreSQL Config**: `.infra/postgresql/provision/conf.d/postgresql.conf`
- **Authentication**: `.infra/postgresql/provision/conf.d/pg_hba.conf`
- **pgAdmin Servers**: `.infra/postgresql/provision/pgadmin/servers.json`

## Container Images

- **PostgreSQL**: `docker.io/schnell18/postgresql:15-alpine-1`
- **pgAdmin**: `docker.io/dpage/pgadmin4:latest`

## Health Checks

Both services include health checks:
- **PostgreSQL**: Uses `pg_isready` command
- **pgAdmin**: Uses HTTP ping endpoint

## Cross-Platform Notes

- **Linux/macOS**: Uses bash scripts in `provision/pre/prepare.sh`
- **Windows**: Uses PowerShell scripts in `provision/pre/prepare.ps1`
- All scripts handle state directory creation and configuration copying

## Troubleshooting

### PostgreSQL won't start
1. Check if port 5432 is available: `netstat -an | grep 5432`
2. Check logs: `./infractl.sh logs postgresql`
3. Verify data directory permissions: `ls -la .state/postgresql/data/`

### pgAdmin won't start
1. Check if port 5050 is available: `netstat -an | grep 5050`
2. Verify PostgreSQL is running first (pgAdmin depends on it)
3. Check pgAdmin logs: `podman logs postgresql_pgadmin_1`

### Can't connect from pgAdmin to PostgreSQL
1. Verify PostgreSQL is healthy: `./infractl.sh status postgresql`
2. Check network connectivity between containers
3. Verify credentials match the configuration
