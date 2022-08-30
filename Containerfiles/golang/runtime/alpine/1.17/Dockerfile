FROM alpine:3.14
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"


ARG GRPC_HEALTH_PROBE_VERSION

RUN cp /etc/apk/repositories /etc/apk/repositories.orig && \
    echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache --update curl bash bash-completion tcpdump iproute2-ss bind-tools jq delve tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    ARCH= && apkArch="$(apk --print-arch)" && \
    case "${apkArch##*-}" in \
        amd64) ARCH='linux-amd64';; \
        x86_64) ARCH='linux-amd64';; \
        arm64) ARCH='linux-arm64';; \
        aarch64) ARCH='linux-arm64';; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac && \
    BIN="grpc_health_probe-${ARCH}" && \
    DOWNLOAD_URL="https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/$BIN" && \
    echo $DOWNLOAD_URL && \
    curl -L --silent ${DOWNLOAD_URL} -o /usr/bin/grpc_health_probe && \
    chmod +x /usr/bin/grpc_health_probe && \
    mv /etc/apk/repositories.orig /etc/apk/repositories && \
    rm -rf /var/cache/apk/*
