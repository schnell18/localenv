# Add topic here
TOPICS="
UTOPIC-ORDER-PAID
UTOPIC-ORDER-PAY-EXPIRE-CHECK
UTOPIC-MOBILE_PAY-PAID
"

# check if broker is running
mqBrokerContainer=$(docker ps -f label=mq_broker=true -q)
if [[ -z $mqBrokerContainer ]]; then
    echo "RocketMQ broker is not running, skip topic creation" 
else
    for t in $TOPICS
    do
        echo "Setup RocketMQ topic $t ..."
        docker exec -it ${mqBrokerContainer} \
            sh /home/rocketmq/rocketmq-4.9.2/bin/mqadmin updateTopic \
               -c devCluster -t $t -w 4 -r 4 > /dev/null
    done

fi



