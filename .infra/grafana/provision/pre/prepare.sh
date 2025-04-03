source .infra/global/libs/functions.sh

if [[ ! -d .state/grafana/data ]]; then
    mkdir -p .state/grafana/data
fi

