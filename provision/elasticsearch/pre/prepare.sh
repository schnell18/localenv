source provision/global/libs/functions.sh

function setup_macos {
    podman machine ssh sed -e '$a * soft memlock -1' \
                           -e '$a * hard memlock -1' \
                           -e '$a * soft nproc 4096' \
                           -e '$a * hard nproc 8192' \
                           /etc/security/limits.d/eslaticsearch.conf
    podman machine ssh sysctl -w vm.max_map_count=262144
}

function setup_linux {
    sudo cat<<EOF > /etc/security/limits.d/eslaticsearch.conf
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
EOF
    sudo sysctl -w vm.max_map_count=262144
}

case `uname` in
    Darwin) setup_macos ;;
    Linux) setup_linux ;;
    *) echo ""
esac

sudo cat<<EOF > /etc/sysctl.d/eslaticsearch.conf
vm.max_map_count = 262144
EOF

if [[ ! -d .state/elasticsearch/es01 ]]; then
    mkdir -p .state/elasticsearch/es01
    # chmod g+rwx .state/elasticsearch/es01
    # chgrp 0 .state/elasticsearch/es01
fi

