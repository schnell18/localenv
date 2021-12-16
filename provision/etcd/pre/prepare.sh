source provision/global/libs/functions.sh

if [[ ! -d .state/etcd/logs ]]; then
    mkdir -p .state/etcd/logs
fi

