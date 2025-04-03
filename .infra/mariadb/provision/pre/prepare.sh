source .infra/global/libs/functions.sh

if [[ ! -d .state/mariadb/data ]]; then
    mkdir -p .state/mariadb/data
fi

