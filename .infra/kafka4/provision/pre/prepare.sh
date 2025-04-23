source .infra/global/libs/functions.sh

function create_dirs {
    local node_no=$1

    if [[ ! -d .state/kafka4/node${node_no}/conf ]]; then
        mkdir -p .state/kafka4/node${node_no}/conf
    fi

    if [[ ! -d .state/kafka4/node${node_no}/logs ]]; then
        mkdir -p .state/kafka4/node${node_no}/logs
    fi

    if [[ ! -d .state/kafka4/node${node_no}/data ]]; then
        mkdir -p .state/kafka4/node${node_no}/data
    fi
}

function generateKafkaConf {
    node_id=$1
    file=$2
    port=$(expr $node_id \* 10000 + 9092)
    hostip=$(getHostIP)
    cat .infra/kafka4/provision/server.properties.tpl | \
        sed "s/@KAFKA_ADV_HOST_PORT@/$hostip:$port/g" | \
        sed "s/@NODE_ID@/$node_id/g" > $file
}

# generate redis config file and use host IP
for node_id in $(seq 1 3); do
    create_dirs $node_id
    generateKafkaConf $node_id ".state/kafka4/node${node_id}/conf/server.properties"
done
