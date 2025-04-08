source .infra/global/libs/functions.sh

if [[ ! -d .state/kafka4/node1/conf ]]; then
    mkdir -p .state/kafka4/node1/conf
fi

if [[ ! -d .state/kafka4/node1/logs ]]; then
    mkdir -p .state/kafka4/node1/logs
fi

if [[ ! -d .state/kafka4/node1/data ]]; then
    mkdir -p .state/kafka4/node1/data
fi

if [[ ! -d .state/kafka4/node2/conf ]]; then
    mkdir -p .state/kafka4/node2/conf
fi

if [[ ! -d .state/kafka4/node2/logs ]]; then
    mkdir -p .state/kafka4/node2/logs
fi

if [[ ! -d .state/kafka4/node2/data ]]; then
    mkdir -p .state/kafka4/node2/data
fi

if [[ ! -d .state/kafka4/node3/conf ]]; then
    mkdir -p .state/kafka4/node3/conf
fi

if [[ ! -d .state/kafka4/node3/logs ]]; then
    mkdir -p .state/kafka4/node3/logs
fi

if [[ ! -d .state/kafka4/node3/data ]]; then
    mkdir -p .state/kafka4/node3/data
fi

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
    generateKafkaConf $node_id ".state/kafka4/node${node_id}/conf/server.properties"
done
