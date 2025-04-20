source .infra/global/libs/functions.sh

if [[ ! -d .state/wekan/data ]]; then
    mkdir -p .state/wekan/data
fi

