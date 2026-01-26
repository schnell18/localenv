ARG VERSION=latest
FROM ghcr.io/nats-nui/nui:${VERSION}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

# Fix for health check failure, see
# https://gist.github.com/schnell18/cb94a8d24f4e643187aa95c629338b2e
RUN apk add --no-cache netcat-openbsd
