# CockroachDB for localenv

This directory contains the configuration for running CockroachDB as
part of the localenv infrastructure.

## Features

- Single-node CockroachDB instance for local development
- Web-based Admin UI accessible at http://localhost:8080
- Pre-configured with localenv user
- Rootful container for easy file sharing
- Insecure mode for simplified local development

## Usage

### Starting CockroachDB

```bash
./infractl.sh start cockroachdb
```

### Checking Status

```bash
./infractl.sh status cockroachdb
```

### Stopping CockroachDB

```bash
./infractl.sh stop cockroachdb
```

### Accessing the Database

- **SQL Port**: 26257
- **Admin UI**: http://localhost:8080
- **Username**: localenv
- **Database**: defaultdb

### Connecting via CLI

```bash
# From host system (if cockroach CLI is installed)
cockroach sql --insecure --host=localhost --port=26257 --user=localenv --database=defaultdb

# From within the container
podman exec -it <container-name> cockroach sql --insecure --user=localenv --database=defaultdb
```

### Connecting via Application

```
Host: localhost
Port: 26257
User: localenv
Database: defaultdb
SSL Mode: disable (insecure mode for local development)
```

## Data Persistence

Database data is persisted in `.state/cockroachdb/data/` directory.

## Configuration

- **Image**: docker.io/schnell18/cockroachdb:v25.2.4-1
- **Database Type**: CockroachDB
- **Ports**: 26257 (SQL), 8080 (Admin UI)
- **Mode**: Insecure (single-node for local development)

## Notes

- This setup is designed for local development only
- Insecure mode is used for simplicity - not suitable for production
- Admin privileges are granted to the localenv user for full access
- The container runs as root for compatibility with localenv patterns
