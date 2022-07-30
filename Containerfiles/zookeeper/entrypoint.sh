#!/bin/bash

CLASSPATH="$ZOOKEEPER_HOME/conf:${JAVA_HOME}/jre/lib/ext"
for ELM in $(ls $ZOOKEEPER_HOME/lib/*.jar); do
    CLASSPATH="$CLASSPATH:$ELM"
done

MAX_HEAP_SIZE=${MAX_HEAP_SIZE:-256M}
HEAP_NEWSIZE=${HEAP_NEWSIZE:-64M}

Xms=$MAX_HEAP_SIZE
Xmx=$MAX_HEAP_SIZE
Xmn=$HEAP_NEWSIZE
MaxDirectMemorySize=$MAX_HEAP_SIZE

ZOOCFG=$ZOOKEEPER_HOME/conf/zoo.cfg
ZOOMAIN="org.apache.zookeeper.server.quorum.QuorumPeerMain"
# Set for `JAVA_OPT`.

JAVA_OPT="${JAVA_OPT} -server -Xms${Xms} -Xmx${Xmx} -Xmn${Xmn}"
JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC -XX:G1HeapRegionSize=16m -XX:G1ReservePercent=25"
JAVA_OPT="${JAVA_OPT} -XX:InitiatingHeapOccupancyPercent=30 -XX:SoftRefLRUPolicyMSPerMB=0"
JAVA_OPT="${JAVA_OPT} -XX:SurvivorRatio=8 -verbose:gc"
JAVA_OPT="${JAVA_OPT} -Xlog:gc*,safepoint:/var/lib/zookeeper/logs/zk_gc_%p.log:time,uptime:filecount=100,filesize=12M"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"
JAVA_OPT="${JAVA_OPT} -XX:+AlwaysPreTouch"
JAVA_OPT="${JAVA_OPT} -XX:MaxDirectMemorySize=${MaxDirectMemorySize}"
JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages -XX:-UseBiasedLocking"
JAVA_OPT="${JAVA_OPT} -cp $CLASSPATH"
#JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"

java ${JAVA_OPT} $ZOOMAIN "$ZOOCFG"


