# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

function Setup-Windows {
    # Create the limits configuration content as a multiline string
    $limitsConfig = @"
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
"@

    # Create the command to be executed on the podman machine
    $podmanCommand = @"
cat<<EOT > /etc/security/limits.d/elasticsearch.conf
$limitsConfig
EOT
sysctl -w vm.max_map_count=262144 > /dev/null
getent passwd 1000 > /dev/null
if [[ `$? -ne 0 ]]; then
 useradd -u 1000 esrunner
fi
chown -R 1000 `$(pwd)/.state/elasticsearch/es01
"@

    # Execute the command on the podman machine
    podman machine ssh --username root localenv $podmanCommand
}

function Setup-Linux {
    # Create the limits configuration file
    $limitsConfig = @"
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
"@

    # Use sudo to write the configuration and set system properties
    $null = sudo mkdir -p /etc/security/limits.d
    $limitsConfig | sudo Out-File -FilePath /etc/security/limits.d/elasticsearch.conf -Encoding ascii
    sudo sysctl -w vm.max_map_count=262144
}

# Create Elasticsearch data directory if it doesn't exist
if (-not (Test-Path ".state\elasticsearch\es01")) {
    New-Item -Path ".state\elasticsearch\es01" -ItemType Directory -Force
    Write-Host "Created Elasticsearch data directory."
}

Setup-Windows
