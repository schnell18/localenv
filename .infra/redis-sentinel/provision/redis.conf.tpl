port @REDIS_PORT@
protected-mode no
appendonly yes
pidfile /var/run/redis.pid
masterauth localenv
requirepass localenv
