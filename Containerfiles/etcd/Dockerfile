ARG ETCD_VERSION
FROM docker.io/bitnami/etcd:${ETCD_VERSION}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

# switch back to root to ease file sharing between container and host
USER root

RUN install_packages curl jq \
    && sed -i -e 's/^if am_i_root; then/if false; then/' /opt/bitnami/scripts/etcd/run.sh
