#/bin/sh

NODE_COUNT=$(redis-cli -h redis-cnode1 -p 7001 -a localenv cluster nodes | wc -l)
if [ $NODE_COUNT -lt 3 ]; then
    echo "yes" | redis-cli -h redis-cnode1 -p 7001 -a localenv \
        --cluster create \
            @CLUSTER_ANNOUNCE_IP@:@REDIS_PORT1@ \
            @CLUSTER_ANNOUNCE_IP@:@REDIS_PORT2@ \
            @CLUSTER_ANNOUNCE_IP@:@REDIS_PORT3@ \
            --cluster-replicas 0
fi

# Make sure creator container does not exit
while true; do
  sleep infinity
done
