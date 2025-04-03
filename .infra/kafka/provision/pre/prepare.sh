source .infra/global/libs/functions.sh

if [[ ! -d .state/kafka/broker1/logs ]]; then
    mkdir -p .state/kafka/broker1/logs
fi

if [[ ! -d .state/kafka/broker1/data ]]; then
    mkdir -p .state/kafka/broker1/data
fi

if [[ ! -d .state/kafka/broker2/logs ]]; then
    mkdir -p .state/kafka/broker2/logs
fi

if [[ ! -d .state/kafka/broker2/data ]]; then
    mkdir -p .state/kafka/broker2/data
fi

if [[ ! -d .state/kafka/broker3/logs ]]; then
    mkdir -p .state/kafka/broker3/logs
fi

if [[ ! -d .state/kafka/broker3/data ]]; then
    mkdir -p .state/kafka/broker3/data
fi

