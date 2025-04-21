source .infra/global/libs/functions.sh

function setup_macos {
    cat<<'EOF' | podman machine ssh --username root localenv
    # Required value
    REQUIRED_START_PORT=80

    # Get current value
    CURRENT_MAX_MAP_COUNT=$(sysctl -n net.ipv4.ip_unprivileged_port_start)

    # Compare current value with required value
    if [[ $CURRENT_MAX_MAP_COUNT -gt $REQUIRED_START_PORT ]]; then
        sudo sysctl -w net.ipv4.ip_unprivileged_port_start=$REQUIRED_START_PORT
    fi
EOF

}

function setup_linux {
    # Required value
    REQUIRED_START_PORT=80

    # Get current value
    CURRENT_MAX_MAP_COUNT=$(sysctl -n net.ipv4.ip_unprivileged_port_start)

    # Compare current value with required value
    if [[ $CURRENT_MAX_MAP_COUNT -gt $REQUIRED_START_PORT ]]; then
        sudo sysctl -w net.ipv4.ip_unprivileged_port_start=$REQUIRED_START_PORT
    fi

}

case `uname` in
    Darwin) setup_macos ;;
    Linux) setup_linux ;;
    *) echo ""
esac
