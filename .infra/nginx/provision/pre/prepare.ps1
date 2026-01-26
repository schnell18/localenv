# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

function Setup-Windows {
    $podmanScript = @'
# Required value
REQUIRED_START_PORT=80

# Get current value
CURRENT_START_PORT=$(sysctl -n net.ipv4.ip_unprivileged_port_start)

# Compare current value with required value
if [[ $CURRENT_START_PORT -gt $REQUIRED_START_PORT ]]; then
    sysctl -w net.ipv4.ip_unprivileged_port_start=$REQUIRED_START_PORT
fi
'@

    Write-Host "Configuring unprivileged port settings for nginx..."
    $podmanScript | & podman machine ssh --username root localenv
}

Setup-Windows
