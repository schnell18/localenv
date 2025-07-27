source .infra/global/libs/functions.sh

if [[ ! -d .state/postgresql/data ]]; then
    mkdir -p .state/postgresql/data
fi

if [[ ! -d .state/postgresql/conf ]]; then
    mkdir -p .state/postgresql/conf
    cp .infra/postgresql/provision/conf.d/* .state/postgresql/conf
fi

if [[ ! -d .state/postgresql/pgadmin ]]; then
    mkdir -p .state/postgresql/pgadmin
fi