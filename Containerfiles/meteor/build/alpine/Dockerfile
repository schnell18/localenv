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
#RUN curl https://install.meteor.com/ | sed -e "s/RELEASE=\"\d\.\d.\d\"/RELEASE=\"$METEOR_VERSION\"/" | sh
RUN curl https://install.meteor.com/ | sh

# work around .meteor/packages/meteor-tool/.2.7.3.1mjjp3y.wu0o++os.linux.x86_64+web.browser+web.browser.legacy+web.cordova/mt-os.linux.x86_64/dev_bundle/bin/node: No such file or directory
RUN sed -i -e 's|exec "$DEV_BUNDLE|exec "/usr/local|' /root/.meteor/packages/meteor-tool/2.7.3/mt-os.linux.x86_64/meteor
