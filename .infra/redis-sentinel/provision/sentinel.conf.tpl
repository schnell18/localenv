port @SENTINEL_PORT@
sentinel monitor mymaster @MASTER_IP@ @MASTER_PORT@ 2
sentinel down-after-milliseconds mymaster 10000
sentinel failover-timeout mymaster 180000
sentinel parallel-syncs mymaster 1

sentinel announce-ip @SENTINEL_ANNOUNCE_IP@
sentinel announce-port @SENTINEL_PORT@
sentinel auth-pass mymaster abc123
