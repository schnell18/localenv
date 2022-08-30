FROM docker.io/library/golang:1.17-alpine
LABEL MAINTAINER="Justin Zhang <schnell18@gmail.com>"
ARG TIMEZONE="Asia/Shanghai"


RUN cp /etc/apk/repositories /etc/apk/repositories.orig && \
    echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache --update curl bash bash-completion \
                                tcpdump iproute2-ss bind-tools \
                                jq delve tzdata \
                                make openssh-client git gcc musl-dev && \
    cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    echo "$TIMEZONE" > /etc/timezone && \
    mv /etc/apk/repositories.orig /etc/apk/repositories && \
    rm -rf /var/cache/apk/*
