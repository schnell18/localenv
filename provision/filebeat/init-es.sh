#!/bin/sh

export PATH=/usr/share/filebeat:$PATH

curl -sL http://es01:9200/_cat/indices | grep filebeat > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Setup index for filebeat..."
    filebeat setup \
        -E setup.kibana.host=kib01:5601 \
        -E output.elasticsearch.hosts=["es01:9200"]
fi
