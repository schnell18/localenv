# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

function Setup-Windows {

    # Create the command to be executed on the podman machine
    $podmanCommand = @"
    # Required value
    REQUIRED_START_PORT=80

    # Get current value
    CURRENT_MAX_MAP_COUNT=`$(sysctl -n net.ipv4.ip_unprivileged_port_start)

    # Compare current value with required value
    if [[ `$CURRENT_MAX_MAP_COUNT -gt `$REQUIRED_START_PORT ]]; then
        sudo sysctl -w net.ipv4.ip_unprivileged_port_start=`$REQUIRED_START_PORT
    fi
"@

    # Execute the command on the podman machine
    podman machine ssh --username root localenv $podmanCommand
}

Setup-Windows
