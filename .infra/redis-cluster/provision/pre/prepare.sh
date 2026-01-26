source .infra/global/libs/functions.sh

function generateRedisConf {
    port=$1
    file=$2
    hostip=$(getHostIP)
    cat .infra/redis-cluster/provision/redis.conf.tpl | \
        sed "s/@REDIS_PORT@/$port/g" | \
        sed "s/@CLUSTER_ANNOUNCE_IP@/$hostip/g" > $file
}

function generateRedisClusterScript {
    port1=$1
    port2=$2
    port3=$3
    file=$4
    hostip=$(getHostIP)
    cat .infra/redis-cluster/provision/create-cluster.sh.tpl | \
        sed "s/@REDIS_PORT1@/$port1/g" | \
        sed "s/@REDIS_PORT2@/$port2/g" | \
        sed "s/@REDIS_PORT3@/$port3/g" | \
        sed "s/@CLUSTER_ANNOUNCE_IP@/$hostip/g" > $file
}

function setup_kernel_params_linux {

    # Required value
    REQUIRED_OVERCOMMIT_MEM=1

    # Get current value
    CURRENT_OVERCOMMIT_MEM=$(sysctl -n vm.overcommit_memory)

    # Compare current value with required value
    if [[ $CURRENT_OVERCOMMIT_MEM -ne $REQUIRED_OVERCOMMIT_MEM ]]; then
        sudo sysctl -w vm.overcommit_memory=$REQUIRED_OVERCOMMIT_MEM
    fi
}

function setup_kernel_params_macos {
    echo "sysctl -w vm.overcommit_memory=1" | podman machine ssh --username root localenv
}

function getPreviousHostIP {
    md_file=$1
    grep ":7001" $md_file | cut -d' ' -f2 | cut -d':' -f1
}

function replaceHostIP {
    md_file=$1
    prev_ip=$2
    curr_ip=$3
    sed -i.bak -e "s/$prev_ip/$curr_ip/g" $md_file
}


# cad1fa378e1574f33543a1b1789599d75be38bb3 192.168.31.183:7002@17002 master - 0 1760472487594 2 connected 5461-10922
# 6bafcbc5ed5f20d39fcf0e1b4c8a2c00875bc719 192.168.31.183:7003@17003 master - 0 1760472487794 3 connected 10923-16383
# fefd2a654a86c7c34411b78fa08a3070dd039d66 192.168.31.183:7001@17001 myself,master - 0 0 1 connected 0-5460
function patch_cluster_metadata {
    for n in $(seq 1 3); do
        # update ip address if announce IP changed
        md_file=".state/redis-cluster/data/node${n}/nodes.conf"
        if [[ -f $md_file ]]; then
            curIP=$(getHostIP)
            prevIP=$(getPreviousHostIP $md_file)
            if [[ $curIP != $prevIP ]]; then
                replaceHostIP $md_file $prevIP $curIP
            fi
        fi
    done
}

patch_cluster_metadata

if [[ ! -d .state/redis-cluster/conf ]]; then
    mkdir -p .state/redis-cluster/conf/{node1,node2,node3}
fi

if [[ ! -d .state/redis-cluster/redis-ui ]]; then
    mkdir -p .state/redis-cluster
    cp -r .infra/redis-cluster/provision/redis-ui .state/redis-cluster/redis-ui
fi

# generate redis config file and use host IP
generateRedisConf 7001 .state/redis-cluster/conf/node1/redis.conf
generateRedisConf 7002 .state/redis-cluster/conf/node2/redis.conf
generateRedisConf 7003 .state/redis-cluster/conf/node3/redis.conf

if [[ ! -d .state/redis-cluster/bin ]]; then
    mkdir -p .state/redis-cluster/bin
fi

rm -fr .state/redis-cluster/bin/create-cluster.sh
touch .state/redis-cluster/bin/create-cluster.sh
chmod +x .state/redis-cluster/bin/create-cluster.sh
# generate redis cluster creation script use host IP
generateRedisClusterScript 7001 7002 7003 .state/redis-cluster/bin/create-cluster.sh

# setup kernel parameters
case $(uname) in
    Darwin) setup_kernel_params_macos ;;
    Linux) setup_kernel_params_linux ;;
    *) echo ""
esac
