source .infra/global/libs/functions.sh

if [[ ! -d .state/fluentbit/logs-vol ]]; then
    mkdir -p .state/fluentbit/logs-vol
fi

