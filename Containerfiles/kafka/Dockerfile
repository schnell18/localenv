FROM docker.io/schnell18/java-runtime-jre:17.0.3-17.34.19-4-alpine 
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

RUN apk add --no-cache bash gettext nmap-ncat openssl busybox-extras

ARG version

# kafka version
ENV KAFKA_VERSION ${version}

# kafka home
ENV KAFKA_HOME  /kafka

WORKDIR  ${KAFKA_HOME}

# Install
RUN set -eux && \
    apk add --virtual .build-deps curl coreutils  gnupg && \
    curl -L https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz -o kafka_2.13-${KAFKA_VERSION}.tgz && \
    curl -L https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz.asc -o kafka_2.13-${KAFKA_VERSION}.tgz.asc && \
    curl -L https://archive.apache.org/dist/kafka/KEYS -o KEYS && \
    gpg --import KEYS && \
    gpg --batch --verify kafka_2.13-${KAFKA_VERSION}.tgz.asc kafka_2.13-${KAFKA_VERSION}.tgz && \
    tar -xzvf kafka_2.13-${KAFKA_VERSION}.tgz && \
	mv kafka_2.13-$KAFKA_VERSION/* . && \
	rmdir kafka_2.13-$KAFKA_VERSION && \
	rm *.tgz *.tgz.asc KEYS && \
	apk del .build-deps && \
    rm -rf /var/cache/apk/*  && \
    rm -rf /tmp/*

EXPOSE 9092

# Export Java options
# RUN export JAVA_OPT=" -Duser.home=/home/kafka"

WORKDIR ${KAFKA_HOME}/bin

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
