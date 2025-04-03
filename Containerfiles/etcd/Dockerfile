ARG ETCD_VERSION
FROM docker.io/bitnami/etcd:${ETCD_VERSION}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

# switch back to root to ease file sharing between container and host
USER root

RUN install_packages curl jq
