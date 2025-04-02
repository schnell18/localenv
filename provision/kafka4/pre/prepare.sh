source provision/global/libs/functions.sh

if [[ ! -d .state/kafka4/node1/logs ]]; then
    mkdir -p .state/kafka4/node1/logs
fi

if [[ ! -d .state/kafka4/node1/data ]]; then
    mkdir -p .state/kafka4/node1/data
fi

if [[ ! -d .state/kafka4/node2/logs ]]; then
    mkdir -p .state/kafka4/node2/logs
fi

if [[ ! -d .state/kafka4/node2/data ]]; then
    mkdir -p .state/kafka4/node2/data
fi

if [[ ! -d .state/kafka4/node3/logs ]]; then
    mkdir -p .state/kafka4/node3/logs
fi

if [[ ! -d .state/kafka4/node3/data ]]; then
    mkdir -p .state/kafka4/node3/data
fi

