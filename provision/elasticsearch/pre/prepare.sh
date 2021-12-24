source provision/global/libs/functions.sh

if [[ ! -d .state/elasticsearch/es01 ]]; then
    mkdir -p .state/elasticsearch/es01
    chmod g+rwx .state/elasticsearch/es01
    chgrp 0 .state/elasticsearch/es01
fi

