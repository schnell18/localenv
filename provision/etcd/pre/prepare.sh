source provision/global/libs/functions.sh

if [[ ! -d .state/etcd/etcd1/logs ]]; then
    mkdir -p .state/etcd/etcd1/logs
    chmod o+rwx .state/etcd/etcd1/logs
fi

if [[ ! -d .state/etcd/etcd1/data ]]; then
    mkdir -p .state/etcd/etcd1/data
    chmod o+rwx .state/etcd/etcd1/data
fi

if [[ ! -d .state/etcd/etcd2/logs ]]; then
    mkdir -p .state/etcd/etcd2/logs
    chmod o+rwx .state/etcd/etcd2/logs
fi

if [[ ! -d .state/etcd/etcd2/data ]]; then
    mkdir -p .state/etcd/etcd2/data
    chmod o+rwx .state/etcd/etcd2/data
fi

if [[ ! -d .state/etcd/etcd3/logs ]]; then
    mkdir -p .state/etcd/etcd3/logs
    chmod o+rwx .state/etcd/etcd3/logs
fi

if [[ ! -d .state/etcd/etcd3/data ]]; then
    mkdir -p .state/etcd/etcd3/data
    chmod o+rwx .state/etcd/etcd3/data
fi

    # chgrp 0 .state/etcd
