source .infra/global/libs/functions.sh

if [[ ! -d .state/prometheus/data ]]; then
    mkdir -p .state/prometheus/data
fi



