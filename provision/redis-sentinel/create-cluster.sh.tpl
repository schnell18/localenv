#/bin/sh

echo "yes" | redis-cli -a abc123 \
  --cluster create \
    @CLUSTER_ANNOUNCE_IP@:@REDIS_PORT1@ \
    @CLUSTER_ANNOUNCE_IP@:@REDIS_PORT2@ \
    @CLUSTER_ANNOUNCE_IP@:@REDIS_PORT3@ \
  --cluster-replicas 0

# Make sure creator container does not exit
while true; do
  sleep 10000
done
