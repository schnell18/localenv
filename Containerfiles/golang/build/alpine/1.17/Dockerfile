FROM docker.io/library/golang:1.17-alpine

RUN cp /etc/apk/repositories /etc/apk/repositories.orig && \
    echo https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache --update curl bash bash-completion \
                                tcpdump iproute2-ss bind-tools \
                                jq delve tzdata \
                                make openssh-client git gcc musl-dev && \
    mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    # echo "StrictHostKeyChecking no " > ~/.ssh/config && \
    # echo "192.168.31.25   git.ucloudadmin.com" >> /etc/hosts && \
    go env -w GOINSECURE=git.ucloudadmin.com && \
    go env -w GOPRIVATE=git.ucloudadmin.com && \
    git config --global url."ssh://git@git.ucloudadmin.com".insteadOf "https://git.ucloudadmin.com" && \
    git config --global url."ssh://git@git.ucloudadmin.com".insteadOf "http://git.ucloudadmin.com" && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    mv /etc/apk/repositories.orig /etc/apk/repositories && \
    rm -rf /var/cache/apk/*
