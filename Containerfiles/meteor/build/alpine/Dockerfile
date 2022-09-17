ARG NODE_IMG_TAG
ARG METEOR_VERSION

FROM docker.io/library/node:${NODE_IMG_TAG}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

ENV METEOR_ALLOW_SUPERUSER true
RUN apk --no-cache add \
    libarchive-tools \
    gnupg \
    wget \
    bzip2 \
    git \
    bash \
    curl \
    g++ \
    make \
    ca-certificates\
    python3
RUN curl https://install.meteor.com/ | sed -e "s/RELEASE=\"\d\.\d.\d\"/RELEASE=\"$METEOR_VERSION\"/" | sh
