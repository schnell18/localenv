ARG RABBITMQ_VERSION
FROM docker.io/library/rabbitmq:${RABBITMQ_VERSION}

LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

RUN apk --no-cache --update add --virtual .shadow-pkgs shadow && \
    set -x && \
    groupmod -g 1000 rabbitmq && \
    usermod -u 1000 -g 1000 rabbitmq && \
    apk del .shadow-pkgs && \
    find / -user 100 | xargs chown -h 1000 2>/dev/null && \
    find / -group 101 | xargs chgrp -h 1000 2>/dev/null
