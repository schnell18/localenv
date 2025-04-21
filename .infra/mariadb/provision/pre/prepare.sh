source .infra/global/libs/functions.sh

if [[ ! -d .state/mariadb/data ]]; then
    mkdir -p .state/mariadb/data
fi

if [[ ! -d .state/mariadb/conf ]]; then
    mkdir -p .state/mariadb/conf
    cp .infra/mariadb/provision/conf.d/* .state/mariadb/conf
fi
