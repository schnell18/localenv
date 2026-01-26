source .infra/global/libs/functions.sh

if [[ ! -d .state/cockroachdb/data ]]; then
    mkdir -p .state/cockroachdb/data
fi
