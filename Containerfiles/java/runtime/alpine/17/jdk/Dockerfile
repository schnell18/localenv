FROM alpine:3.15
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

ARG ZULU_VERSION
ARG OPENJDK_VERSION

RUN apk add --no-cache --update curl bash tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    ARCH= && apkArch="$(apk --print-arch)" \
  && case "${apkArch##*-}" in \
    amd64) ARCH='x64';; \
    x86_64) ARCH='x64';; \
    arm64) ARCH='aarch64';; \
    aarch64) ARCH='aarch64';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac ;\
  ZULU_JDK="zulu${ZULU_VERSION}-ca-jdk${OPENJDK_VERSION}-linux_musl_${ARCH}"; \
  ZULU_DOWNLOAD_URL="https://cdn.azul.com/zulu/bin/${ZULU_JDK}.tar.gz" ; \
  curl -L --silent ${ZULU_DOWNLOAD_URL} | tar -xzf - -C / && mv /$ZULU_JDK /jdk; \
  apk del tzdata

ENV PATH $PATH:/jdk/bin
ENV JAVA_HOME /jdk
