# CockroachDB for localenv

This directory contains the configuration for running CockroachDB as
part of the localenv infrastructure.

## Features

- Three-node CockroachDB cluster for local development
- High availability and distributed SQL capabilities
- Multiple Admin UI interfaces for each node
- Pre-configured with localenv user
- Rootful containers for easy file sharing
- Insecure mode for simplified local development

## Usage

### Starting CockroachDB Cluster

```bash
./infractl.sh start cockroachdb
```

### Checking Status

```bash
./infractl.sh status cockroachdb
```

### Stopping CockroachDB Cluster

```bash
./infractl.sh stop cockroachdb
```

### Accessing the Database

- **Node 1 SQL Port**: 26257
- **Node 2 SQL Port**: 26258
- **Node 3 SQL Port**: 26259
- **Node 1 Admin UI**: http://localhost:8080
- **Node 2 Admin UI**: http://localhost:8081
- **Node 3 Admin UI**: http://localhost:8082
- **Username**: localenv
- **Database**: defaultdb

### Connecting via CLI

```bash
# Connect to Node 1 from host system (if cockroach CLI is installed)
cockroach sql --insecure --host=localhost --port=26257 --user=localenv --database=defaultdb

# Connect to Node 2 from host system
cockroach sql --insecure --host=localhost --port=26258 --user=localenv --database=defaultdb

# Connect to Node 3 from host system
cockroach sql --insecure --host=localhost --port=26259 --user=localenv --database=defaultdb

# From within any container
podman exec -it <container-name> cockroach sql --insecure --user=localenv --database=defaultdb
```

### Connecting via Application

You can connect to any node for load balancing:

```
# Node 1
Host: localhost
Port: 26257
User: localenv
Database: defaultdb
SSL Mode: disable (insecure mode for local development)

# Node 2
Host: localhost
Port: 26258
User: localenv
Database: defaultdb
SSL Mode: disable (insecure mode for local development)

# Node 3
Host: localhost
Port: 26259
User: localenv
Database: defaultdb
SSL Mode: disable (insecure mode for local development)
```

## Data Persistence

Database data is persisted in separate directories for each node:
- Node 1: `.state/cockroachdb/node1/`
- Node 2: `.state/cockroachdb/node2/`
- Node 3: `.state/cockroachdb/node3/`

## Configuration

- **Image**: docker.io/schnell18/cockroachdb:v25.2.4-2
- **Database Type**: CockroachDB
- **Cluster Nodes**: 3
- **Node 1 Ports**: 26257 (SQL), 8080 (Admin UI)
- **Node 2 Ports**: 26258 (SQL), 8081 (Admin UI)
- **Node 3 Ports**: 26259 (SQL), 8082 (Admin UI)
- **Mode**: Insecure (three-node cluster for local development)

## Cluster Information

This setup creates a distributed CockroachDB cluster with:
- **Replication Factor**: 3 (data is replicated across all nodes)
- **Fault Tolerance**: Can survive 1 node failure
- **Load Distribution**: Queries can be distributed across nodes
- **Automatic Failover**: Built-in high availability

## Notes

- This setup is designed for local development only
- Insecure mode is used for simplicity - not suitable for production
- Admin privileges are granted to the localenv user for full access
- The containers run as root for compatibility with localenv patterns
- Node 1 initializes the cluster and creates the localenv user
- Nodes 2 and 3 automatically join the cluster started by Node 1
