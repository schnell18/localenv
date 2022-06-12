source provision/global/libs/functions.sh

sudo cat<<EOF > /etc/security/limits.d/eslaticsearch.conf
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
EOF

sudo sysctl -w vm.max_map_count=262144

sudo cat<<EOF > /etc/sysctl.d/eslaticsearch.conf
vm.max_map_count = 262144
EOF

if [[ ! -d .state/elasticsearch/es01 ]]; then
    mkdir -p .state/elasticsearch/es01
    chmod g+rwx .state/elasticsearch/es01
    chgrp 0 .state/elasticsearch/es01
fi

