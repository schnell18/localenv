ARG JRE_RUNTIME_IMG_TAG
FROM quay.io/schnell18/java-runtime-jre:${JRE_RUNTIME_IMG_TAG}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

RUN apk add --no-cache bash gettext nmap-ncat openssl busybox-extras

# Rocketmq version
ARG ROCKETMQ_VERSION

# Rocketmq home
ENV ROCKETMQ_HOME /home/rocketmq/rocketmq-${ROCKETMQ_VERSION}

WORKDIR ${ROCKETMQ_HOME}

# Install
RUN set -eux; \
    apk add --virtual .build-deps curl gnupg unzip; \
    curl -L https://archive.apache.org/dist/rocketmq/${ROCKETMQ_VERSION}/rocketmq-all-${ROCKETMQ_VERSION}-bin-release.zip -o rocketmq.zip; \
    curl -L https://archive.apache.org/dist/rocketmq/${ROCKETMQ_VERSION}/rocketmq-all-${ROCKETMQ_VERSION}-bin-release.zip.asc -o rocketmq.zip.asc; \
    curl -L https://www.apache.org/dist/rocketmq/KEYS -o KEYS; \
    gpg --import KEYS; \
    gpg --batch --verify rocketmq.zip.asc rocketmq.zip; \
    unzip rocketmq.zip; \
    mv rocketmq-$ROCKETMQ_VERSION/* . ; \
    rmdir rocketmq-$ROCKETMQ_VERSION; \
    rm rocketmq.zip rocketmq.zip.asc KEYS; \
    apk del .build-deps ; \
    rm -rf /var/cache/apk/* ; \
    rm -rf /tmp/*

# Copy customized scripts
COPY scripts/* ${ROCKETMQ_HOME}/bin/

# Expose namesrv port
EXPOSE 9876

# Override customized scripts for namesrv
RUN mv ${ROCKETMQ_HOME}/bin/runserver-customize.sh ${ROCKETMQ_HOME}/bin/runserver.sh \
 && chmod a+x ${ROCKETMQ_HOME}/bin/runserver.sh \
 && chmod a+x ${ROCKETMQ_HOME}/bin/mqnamesrv

# Expose broker ports
EXPOSE 10909 10911 10912

# Override customized scripts for broker
RUN mv ${ROCKETMQ_HOME}/bin/runbroker-customize.sh ${ROCKETMQ_HOME}/bin/runbroker.sh \
 && chmod a+x ${ROCKETMQ_HOME}/bin/runbroker.sh \
 && chmod a+x ${ROCKETMQ_HOME}/bin/mqbroker

# Export Java options
RUN export JAVA_OPT=" -Duser.home=/home/rocketmq"

WORKDIR ${ROCKETMQ_HOME}/bin
