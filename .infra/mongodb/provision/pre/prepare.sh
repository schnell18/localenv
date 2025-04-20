source .infra/global/libs/functions.sh

if [[ ! -d .state/mongodb/data ]]; then
    mkdir -p .state/mongodb/data
fi
