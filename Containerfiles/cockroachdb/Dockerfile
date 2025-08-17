ARG COCKROACHDB_VERSION
FROM docker.io/cockroachdb/cockroach:${COCKROACHDB_VERSION}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

# switch back to root to ease file sharing between container and host
USER root

# Expose CockroachDB ports
EXPOSE 26257 8080

# Create entrypoint script that starts CockroachDB and sets up the user
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
