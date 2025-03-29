source provision/global/libs/functions.sh

if [[ ! -d .state/kafka4/broker1/logs ]]; then
    mkdir -p .state/kafka4/broker1/logs
fi

if [[ ! -d .state/kafka4/broker1/data ]]; then
    mkdir -p .state/kafka4/broker1/data
fi

if [[ ! -d .state/kafka4/broker2/logs ]]; then
    mkdir -p .state/kafka4/broker2/logs
fi

if [[ ! -d .state/kafka4/broker2/data ]]; then
    mkdir -p .state/kafka4/broker2/data
fi

if [[ ! -d .state/kafka4/broker3/logs ]]; then
    mkdir -p .state/kafka4/broker3/logs
fi

if [[ ! -d .state/kafka4/broker3/data ]]; then
    mkdir -p .state/kafka4/broker3/data
fi

