ARG JDK_RUNTIME_IMG_TAG
FROM quay.io/schnell18/java-runtime-jdk:${JDK_RUNTIME_IMG_TAG}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

ARG MAVEN_VERSION=3.8.5
ARG CHECKSUM=89ab8ece99292476447ef6a6800d9842bbb60787b9b8a45c103aa61d2f205a971d8c3ddfb8b03e514455b4173602bd015e82958c0b3ddc1728a57126f773c743
ARG BASE_URL=https://mirror.sjtu.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries


# maven home
ENV MAVEN_HOME /maven

WORKDIR  ${MAVEN_HOME}


# Install
RUN set -eux && \
    apk add --update --no-cache bash git openssh-client coreutils curl gettext nmap-ncat busybox-extras && \
    mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    echo "StrictHostKeyChecking no " > ~/.ssh/config && \
    curl -L ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o maven-${MAVEN_VERSION}.tgz && \
    echo "${CHECKSUM} maven-${MAVEN_VERSION}.tgz" | sha512sum -c - && \
    tar -xzvf maven-${MAVEN_VERSION}.tgz && \
	mv apache-maven-$MAVEN_VERSION/* . && \
	rmdir apache-maven-$MAVEN_VERSION && \
	rm *.tgz && \
    rm -rf /tmp/*

ENV PATH ${MAVEN_HOME}/bin:$PATH
