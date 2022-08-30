#!/bin/sh

CLASSPATH="$ROCKETMQ_HOME/conf:${JAVA_HOME}/jre/lib/ext"
for ELM in $(ls $ROCKETMQ_HOME/lib/*.jar); do
    CLASSPATH="$CLASSPATH:$ELM"
done
MAX_HEAP_SIZE=256M
HEAP_NEWSIZE=64M

Xms=$MAX_HEAP_SIZE
Xmx=$MAX_HEAP_SIZE
Xmn=$HEAP_NEWSIZE
MaxDirectMemorySize=$MAX_HEAP_SIZE
# Set for `JAVA_OPT`.

JAVA_OPT="${JAVA_OPT} -server -Xms${Xms} -Xmx${Xmx} -Xmn${Xmn}"
JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC -XX:G1HeapRegionSize=16m -XX:G1ReservePercent=25"
JAVA_OPT="${JAVA_OPT} -XX:InitiatingHeapOccupancyPercent=30 -XX:SoftRefLRUPolicyMSPerMB=0"
JAVA_OPT="${JAVA_OPT} -XX:SurvivorRatio=8 -verbose:gc"
JAVA_OPT="${JAVA_OPT} -Xlog:gc*,safepoint:/home/rocketmq/logs/mq_gc_%p.log:time,uptime:filecount=100,filesize=12M"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"
JAVA_OPT="${JAVA_OPT} -XX:+AlwaysPreTouch"
JAVA_OPT="${JAVA_OPT} -XX:MaxDirectMemorySize=${MaxDirectMemorySize}"
JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages -XX:-UseBiasedLocking"
#JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"
JAVA_OPT="${JAVA_OPT} -cp ${CLASSPATH}"

java ${JAVA_OPT} org.apache.rocketmq.namesrv.NamesrvStartup $@

