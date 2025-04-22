# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

function Setup-Windows {
    $podmanCommand = @"
echo '* soft memlock -1' > /etc/security/limits.d/elasticsearch.conf
echo '* hard memlock -1' >> /etc/security/limits.d/elasticsearch.conf
echo '* soft nproc 4096' >> /etc/security/limits.d/elasticsearch.conf
echo '* hard nproc 8192' >> /etc/security/limits.d/elasticsearch.conf
sysctl -w vm.max_map_count=262144 > /dev/null
"@

# getent passwd 1000 > /dev/null
# if [[ `$? -ne 0 ]]; then
#  useradd -u 1000 esrunner
# fi
    # chown -R 1000 .state/elasticsearch/es01
    # Execute the command on the podman machine
    & podman machine ssh --username root localenv $podmanCommand
}

# Create Elasticsearch data directory if it doesn't exist
if (-not (Test-Path ".state\elasticsearch\es01")) {
    New-Item -Path ".state\elasticsearch\es01" -ItemType Directory -Force
    Write-Host "Created Elasticsearch data directory."
}

Setup-Windows
