source .infra/global/libs/functions.sh
function generateBrokerConf {
    broker=$1
    file=$2
    cat .infra/rocketmq/provision/$broker/conf/broker.conf > $file
    echo "brokerIP1=$(getHostIP)" >> $file
}


if [[ ! -d .state/rocketmq/namesrv/logs ]]; then
    mkdir -p .state/rocketmq/namesrv/logs
fi

if [[ ! -d .state/rocketmq/broker1/conf ]]; then
    mkdir -p .state/rocketmq/broker1/conf
    if [[ -d .state/rocketmq/broker1/conf/broker.conf ]]; then
        # remove broker.conf as a directory
        rm -fr .state/rocketmq/broker1/conf/broker.conf
    fi

fi

# generate broker config file and use host IP
touch .state/rocketmq/broker1/conf/broker.conf
generateBrokerConf broker1 .state/rocketmq/broker1/conf/broker.conf

if [[ ! -d .state/rocketmq/broker1/logs ]]; then
    mkdir -p .state/rocketmq/broker1/logs
fi

if [[ ! -d .state/rocketmq/broker1/store/commitLog ]]; then
    mkdir -p .state/rocketmq/broker1/store/commitLog
fi

if [[ ! -d .state/rocketmq/broker1/store/consumequeue ]]; then
    mkdir -p .state/rocketmq/broker1/store/consumequeue
fi

if [[ ! -d .state/rocketmq/broker2/logs ]]; then
    mkdir -p .state/rocketmq/broker2/logs
fi

if [[ ! -d .state/rocketmq/broker2/store/commitLog ]]; then
    mkdir -p .state/rocketmq/broker2/store/commitLog
fi

if [[ ! -d .state/rocketmq/broker2/store/consumequeue ]]; then
    mkdir -p .state/rocketmq/broker2/store/consumequeue
fi

if [[ ! -d .state/rocketmq/dashboard/logs ]]; then
    mkdir -p .state/rocketmq/dashboard/logs
fi

if [[ ! -d .state/rocketmq/dashboard/data ]]; then
    mkdir -p .state/rocketmq/dashboard/data
fi

