ARG KAFKA_VERSION
FROM docker.io/apache/kafka:${KAFKA_VERSION}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

# switch back to root to ease file sharing between container and host
USER root

# change server.properties location to /etc/kafka/config
# add libstdc++ to support kafka streams (RocksDB dep)
RUN sed -i 's#/opt/kafka/config/server.properties#/opt/kafka/config/kraft/server.properties#' /etc/kafka/docker/launch && \
    apk add --no-cache libstdc++
