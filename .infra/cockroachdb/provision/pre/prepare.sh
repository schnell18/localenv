source .infra/global/libs/functions.sh

# Create directories for three-node cluster
if [[ ! -d .state/cockroachdb/node1 ]]; then
    mkdir -p .state/cockroachdb/node1
fi

if [[ ! -d .state/cockroachdb/node2 ]]; then
    mkdir -p .state/cockroachdb/node2
fi

if [[ ! -d .state/cockroachdb/node3 ]]; then
    mkdir -p .state/cockroachdb/node3
fi
