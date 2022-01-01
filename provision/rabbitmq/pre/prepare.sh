source provision/global/libs/functions.sh

if [[ ! -d .state/rabbitmq ]]; then
    mkdir -p .state/rabbitmq
fi

