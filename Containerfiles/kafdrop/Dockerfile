ARG KAFDROP_VERSION
ARG JRE_RUNTIME_IMG_TAG
FROM docker.io/obsidiandynamics/kafdrop:${KAFDROP_VERSION} as upstream

FROM quay.io/schnell18/java-runtime-jre:${JRE_RUNTIME_IMG_TAG}
LABEL MAINTAINER Justin Zhang "schnell18@gmail.com"

RUN apk add --no-cache bash gettext nmap-ncat openssl busybox-extras
COPY --from=upstream /kafdrop.sh /kafdrop.sh
COPY --from=upstream /kafdrop-* /kafdrop/
RUN chmod +x /kafdrop.sh
EXPOSE 9000

ENTRYPOINT ["/kafdrop.sh"]
