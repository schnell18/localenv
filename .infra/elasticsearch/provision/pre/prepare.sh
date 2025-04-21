source .infra/global/libs/functions.sh

# Required values
REQUIRED_SOFT_NPROC=4096
REQUIRED_HARD_NPROC=8192

# Function to get current limit value
get_current_limit() {
    local limit_type=$1  # "soft" or "hard"
    local resource=$2    # "nproc"

    # Get current limit from ulimit
    if [[ "$limit_type" == "soft" ]]; then
        ulimit -S -$resource 2>/dev/null || echo "unlimited"
    else
        ulimit -H -$resource 2>/dev/null || echo "unlimited"
    fi
}

# Convert "unlimited" to a very large number for comparison
convert_to_number() {
    local value=$1
    if [[ "$value" == "unlimited" ]]; then
        echo 9007199254740991  # A very large number (JavaScript's MAX_SAFE_INTEGER)
    else
        echo $value
    fi
}

function setup_macos {
    cat<<EOF | podman machine ssh --username root localenv
cat<<EOT > /etc/security/limits.d/elasticsearch.conf
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
EOT
sysctl -w vm.max_map_count=262144 > /dev/null
getent passwd 1000 > /dev/null
if [[ $? -ne 0 ]]; then
 useradd -u 1000 esrunner
fi
chown -R 1000 $(pwd)/.state/elasticsearch/es01
EOF
#chown -R esrunner /Users/user/localenv/.state/elasticsearch/es01

}

function setup_linux {

    sudo mkdir -p /etc/security/limits.d
    # Maximum amount of memory Elasticsearch process can lock into RAM
    echo "* soft memlock -1" | sudo tee /etc/security/limits.d/elasticsearch.conf 1>/dev/null
    echo "* hard memlock -1" | sudo tee -a /etc/security/limits.d/elasticsearch.conf 1>/dev/null

    # Required value
    REQUIRED_MAX_MAP_COUNT=262144

    # Get current value
    CURRENT_MAX_MAP_COUNT=$(sysctl -n vm.max_map_count)

    # Compare current value with required value
    if [[ $CURRENT_MAX_MAP_COUNT -lt $REQUIRED_MAX_MAP_COUNT ]]; then
        sudo sysctl -w vm.max_map_count=$REQUIRED_MAX_MAP_COUNT
    fi

    # Get current limits
    CURRENT_SOFT_NPROC=$(get_current_limit "soft" "u")
    CURRENT_HARD_NPROC=$(get_current_limit "hard" "u")

    # Convert to numbers for comparison
    CURRENT_SOFT_NPROC_NUM=$(convert_to_number $CURRENT_SOFT_NPROC)
    CURRENT_HARD_NPROC_NUM=$(convert_to_number $CURRENT_HARD_NPROC)

    if [[ $CURRENT_SOFT_NPROC_NUM -lt $REQUIRED_SOFT_NPROC ]]; then
        echo "* soft nproc 4096" | sudo tee -a /etc/security/limits.d/elasticsearch.conf 1>/dev/null
    fi

    if [[ $CURRENT_HARD_NPROC_NUM -lt $REQUIRED_HARD_NPROC ]]; then
        echo "* hard nproc 8192" | sudo tee -a /etc/security/limits.d/elasticsearch.conf 1>/dev/null
    fi

}

if [[ ! -d .state/elasticsearch/es01 ]]; then
    mkdir -p .state/elasticsearch/es01
fi

case `uname` in
    Darwin) setup_macos ;;
    Linux) setup_linux ;;
    *) echo ""
esac
