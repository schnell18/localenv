FROM golang:1.17-alpine

RUN apk add make openssh-client git && \
    mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    # echo "StrictHostKeyChecking no " > ~/.ssh/config && \
    # echo "192.168.31.25   tinker.cf" >> /etc/hosts && \
    go env -w GOINSECURE=tinker.cf && \
    go env -w GOPRIVATE=tinker.cf && \
    go env -w GOPROXY="http://tinker.cf:8081/repository/gonexus/,direct" && \
    git config --global url."ssh://git@tinker.cf".insteadOf "https://tinker.cf" && \
    git config --global url."ssh://git@tinker.cf".insteadOf "http://tinker.cf"
