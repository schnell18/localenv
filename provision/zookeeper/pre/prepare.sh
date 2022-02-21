source provision/global/libs/functions.sh

if [[ ! -d .state/zookeeper/zk1/logs ]]; then
    mkdir -p .state/zookeeper/zk1/logs
fi

if [[ ! -d .state/zookeeper/zk1/data ]]; then
    mkdir -p .state/zookeeper/zk1/data
    echo "1" > .state/zookeeper/zk1/data/myid
fi

if [[ ! -d .state/zookeeper/zk2/logs ]]; then
    mkdir -p .state/zookeeper/zk2/logs
fi

if [[ ! -d .state/zookeeper/zk2/data ]]; then
    mkdir -p .state/zookeeper/zk2/data
    echo "2" > .state/zookeeper/zk2/data/myid
fi

if [[ ! -d .state/zookeeper/zk3/logs ]]; then
    mkdir -p .state/zookeeper/zk3/logs
fi

if [[ ! -d .state/zookeeper/zk3/data ]]; then
    mkdir -p .state/zookeeper/zk3/data
    echo "3" > .state/zookeeper/zk3/data/myid
fi

