# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

function Setup-Windows {
    $podmanScript = @'
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
'@

    Write-Host "Configuring Elasticsearch settings in podman machine..."
    $podmanScript | & podman machine ssh --username root localenv

    # Set ownership of data directory
    $currentPath = (Get-Location).Path
    & podman machine ssh --username root localenv "chown -R 1000 $currentPath/.state/elasticsearch/es01"
}

# Create Elasticsearch data directory if it doesn't exist
if (-not (Test-Path ".state\elasticsearch\es01")) {
    New-Item -Path ".state\elasticsearch\es01" -ItemType Directory -Force
    Write-Host "Created Elasticsearch data directory."
}

Setup-Windows
