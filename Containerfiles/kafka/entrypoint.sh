#!/bin/bash

CLASSPATH="$KAFKA_HOME/conf:${JAVA_HOME}/jre/lib/ext"
for ELM in $(ls $KAFKA_HOME/libs/*.jar); do
    CLASSPATH="$CLASSPATH:$ELM"
done

MAX_HEAP_SIZE=${MAX_HEAP_SIZE:-256M}
HEAP_NEWSIZE=${HEAP_NEWSIZE:-64M}

Xms=$MAX_HEAP_SIZE
Xmx=$MAX_HEAP_SIZE
Xmn=$HEAP_NEWSIZE
MaxDirectMemorySize=$MAX_HEAP_SIZE

KAFKA_CFG=$KAFKA_HOME/config/server.properties
KAFKA_MAIN="kafka.Kafka"

# Set for `JAVA_OPT`.
JAVA_OPT="${JAVA_OPT} -server -Xms${Xms} -Xmx${Xmx} -Xmn${Xmn}"
JAVA_OPT="${JAVA_OPT} -XX:MaxGCPauseMillis=20 -XX:+ExplicitGCInvokesConcurrent"
JAVA_OPT="${JAVA_OPT} -XX:MaxInlineLevel=15 -Djava.awt.headless=true"
JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC -XX:G1HeapRegionSize=16m -XX:G1ReservePercent=25"
JAVA_OPT="${JAVA_OPT} -XX:InitiatingHeapOccupancyPercent=35 -XX:SoftRefLRUPolicyMSPerMB=0"
JAVA_OPT="${JAVA_OPT} -XX:SurvivorRatio=8 -verbose:gc"
JAVA_OPT="${JAVA_OPT} -Xlog:gc*,safepoint:/var/lib/kafka/logs/broker_gc_%p.log:time,tags:filecount=10,filesize=100M"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"
JAVA_OPT="${JAVA_OPT} -XX:+AlwaysPreTouch"
JAVA_OPT="${JAVA_OPT} -XX:MaxDirectMemorySize=${MaxDirectMemorySize}"
JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages -XX:-UseBiasedLocking"
JAVA_OPT="${JAVA_OPT} -Dkafka.logs.dir=/var/lib/kafka/logs"
JAVA_OPT="${JAVA_OPT} -Dlog4j.configuration=file:/kafka/config/log4j.properties"
JAVA_OPT="${JAVA_OPT} -cp $CLASSPATH"

#JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"

java ${JAVA_OPT} $KAFKA_MAIN $KAFKA_CFG


