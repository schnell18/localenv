FROM docker.io/library/golang:1.19.0-alpine3.15
LABEL MAINTAINER="Justin Zhang <schnell18@gmail.com>"
ARG TIMEZONE="Asia/Shanghai"


RUN cp /etc/apk/repositories /etc/apk/repositories.orig && \
    echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache --update curl bash bash-completion \
                                tcpdump iproute2-ss bind-tools \
                                jq delve tzdata \
                                make openssh-client git gcc musl-dev && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    mv /etc/apk/repositories.orig /etc/apk/repositories && \
    rm -rf /var/cache/apk/*
