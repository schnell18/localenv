source .infra/global/libs/functions.sh

if [[ ! -d .state/tidb/pd/data ]]; then
    mkdir -p .state/tidb/pd/data
fi

if [[ ! -d .state/tidb/pd/logs ]]; then
    mkdir -p .state/tidb/pd/logs
fi

if [[ ! -d .state/tidb/tidb/logs ]]; then
    mkdir -p .state/tidb/tidb/logs
fi

if [[ ! -d .state/tidb/tikv/data ]]; then
    mkdir -p .state/tidb/tikv/data
fi

if [[ ! -d .state/tidb/tikv/logs ]]; then
    mkdir -p .state/tidb/tikv/logs
fi

