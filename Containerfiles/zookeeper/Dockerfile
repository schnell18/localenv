ARG JRE_RUNTIME_IMG_TAG
FROM docker.io/schnell18/java-runtime-jre:${JRE_RUNTIME_IMG_TAG}
MAINTAINER "schnell18@gmail.com"

# zookeeper version
ARG ZOOKEEPER_VERSION

RUN apk add --no-cache bash gettext nmap-ncat openssl busybox-extras

# zookeeper home
ENV ZOOKEEPER_HOME  /zookeeper

WORKDIR  ${ZOOKEEPER_HOME}

# Install
RUN set -eux && \
    apk add --virtual .build-deps curl coreutils && \
    curl -L https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -o apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
    curl -L https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512 -o apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512 && \
    sha512sum -c apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.sha512 && \
    tar -xzvf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
    mv apache-zookeeper-$ZOOKEEPER_VERSION-bin/* . && \
    rmdir apache-zookeeper-$ZOOKEEPER_VERSION-bin && \
    rm *.tar.gz *.tar.gz.sha512 && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*  && \
    rm -rf /tmp/*

EXPOSE 2181

# Export Java options

WORKDIR ${ZOOKEEPER_HOME}/bin

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
