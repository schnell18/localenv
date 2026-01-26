port @REDIS_PORT@
protected-mode no
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip @CLUSTER_ANNOUNCE_IP@
cluster-announce-port @REDIS_PORT@
pidfile /var/run/redis.pid
masterauth localenv
requirepass localenv

# Persistence RDB
dbfilename dump.rdb
dir /data
save 900 1
save 300 10
save 60 10000
# Persistence AOF
appendonly yes
appendfsync everysec
# trigger rewrite when AOF size is 2x since last rewrite
auto-aof-rewrite-percentage 100
# don't rewrite if AOF is smaller than this
auto-aof-rewrite-min-size 64mb

