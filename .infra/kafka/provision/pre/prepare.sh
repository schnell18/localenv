source .infra/global/libs/functions.sh

function create_dirs {
    local broker_no=$1
    if [[ ! -d .state/kafka/broker${broker_no}/logs ]]; then
        mkdir -p .state/kafka/broker${broker_no}/logs
    fi

    if [[ ! -d .state/kafka/broker${broker_no}/data ]]; then
        mkdir -p .state/kafka/broker${broker_no}/data
    fi
}

for broker_no in 1 2 3; do
    create_dirs $broker_no
done
