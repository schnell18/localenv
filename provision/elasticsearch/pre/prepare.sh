source provision/global/libs/functions.sh

# check vm.max_map_count of host to ensure it is no less than 262144
vmMaxMapCount=$(sysctl vm.max_map_count | cut -d' ' -f3)
if [[ $vmMaxMapCount -lt 262144 ]]; then
    # we don't persist the setting
    echo "Set vm.max_map_count to 262144..."
    sudo sysctl -w vm.max_map_count=262144
fi

if [[ ! -d .state/elasticsearch/es01 ]]; then
    mkdir -p .state/elasticsearch/es01
    chmod g+rwx .state/elasticsearch/es01
    sudo chgrp 0 .state/elasticsearch/es01
fi

