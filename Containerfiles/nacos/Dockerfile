ARG JRE_RUNTIME_IMG_TAG
FROM docker.io/schnell18/java-runtime-jre:${JRE_RUNTIME_IMG_TAG}
MAINTAINER "schnell18@gmail.com"

ARG NACOS_VERSION
ARG HOT_FIX_FLAG=""

# set environment
ENV MODE="cluster" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
    CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
    FUNCTION_MODE="all" \
    JAVA_HOME="/jre" \
    NACOS_USER="nacos" \
    JAVA="/jre/bin/java" \
    JVM_XMS="1g" \
    JVM_XMX="1g" \
    JVM_XMN="512m" \
    JVM_MS="128m" \
    JVM_MMS="320m" \
    NACOS_DEBUG="n" \
    TOMCAT_ACCESSLOG_ENABLED="false"

RUN curl -L --silent https://github.com/alibaba/nacos/releases/download/${NACOS_VERSION}${HOT_FIX_FLAG}/nacos-server-${NACOS_VERSION}.tar.gz | \
    tar -xzvf - -C /home && \
    rm -rf /home/nacos/bin/* /home/nacos/conf/*.properties /home/nacos/conf/*.example /home/nacos/conf/nacos-mysql.sql

WORKDIR $BASE_DIR

ADD bin/docker-startup.sh bin/docker-startup.sh
ADD conf/application.properties conf/application.properties
ADD init.d/custom.properties init.d/custom.properties

# set startup log dir
RUN chmod +x bin/docker-startup.sh \
    && mkdir -p logs \
	&& cd logs \
	&& touch start.out \
	&& ln -sf /dev/stdout start.out \
	&& ln -sf /dev/stderr start.out

# switch back to root to ease file sharing between container and host
USER root

EXPOSE 8848
ENTRYPOINT ["bin/docker-startup.sh"]
