# Import global functions (assuming there's a PowerShell equivalent)
# . ".\.infra\global\libs\functions.ps1"

function GenerateMasterRedisConf {
    param(
        [string]$port,
        [string]$file
    )
    (Get-Content ".\.infra\redis-sentinel\provision\redis.conf.tpl") -replace "@REDIS_PORT@", $port |
        Set-Content -Path $file
}

function GenerateSlaveRedisConf {
    param(
        [string]$port,
        [string]$file,
        [string]$master_port,
        [string]$master_ip
    )
    (Get-Content ".\.infra\redis-sentinel\provision\redis-slave.conf.tpl") -replace "@REDIS_PORT@", $port -replace "@MASTER_IP@", $master_ip -replace "@MASTER_PORT@", $master_port |
        Set-Content -Path $file
}

function GenerateSentinelConf {
    param(
        [string]$sentinel_port,
        [string]$file,
        [string]$master_port,
        [string]$hostip,
        [string]$masterip
    )
    (Get-Content ".\.infra\redis-sentinel\provision\sentinel.conf.tpl") -replace "@SENTINEL_PORT@", $sentinel_port -replace "@MASTER_IP@", $masterip -replace "@MASTER_PORT@", $master_port -replace "@SENTINEL_ANNOUNCE_IP@", $hostip |
        Set-Content -Path $file
}

function GetHostIP {
    # This is a placeholder for the getHostIP function from the original script
    # You would replace this with your actual IP retrieval logic
    return (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet | Where-Object {$_.IPAddress -notlike "127.*"}).IPAddress
}

# Create data directories if they don't exist
if (-not (Test-Path ".state\redis-sentinel\data")) {
    New-Item -Path ".state\redis-sentinel\data\node1" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\data\node2" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\data\node3" -ItemType Directory -Force
}

# Create config directories if they don't exist
if (-not (Test-Path ".state\redis-sentinel\conf")) {
    New-Item -Path ".state\redis-sentinel\conf\node1" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\conf\node2" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\conf\node3" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\conf\sentinel1" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\conf\sentinel2" -ItemType Directory -Force
    New-Item -Path ".state\redis-sentinel\conf\sentinel3" -ItemType Directory -Force
}

# Generate Redis config files
GenerateMasterRedisConf -port "6379" -file ".state\redis-sentinel\conf\node1\redis.conf"

$hostip = GetHostIP
GenerateSlaveRedisConf -port "6380" -file ".state\redis-sentinel\conf\node2\redis.conf" -master_port "6379" -master_ip $hostip
GenerateSlaveRedisConf -port "6381" -file ".state\redis-sentinel\conf\node3\redis.conf" -master_port "6379" -master_ip $hostip

GenerateSentinelConf -sentinel_port "5001" -file ".state\redis-sentinel\conf\sentinel1\sentinel.conf" -master_port "6379" -hostip $hostip -masterip $hostip
GenerateSentinelConf -sentinel_port "5002" -file ".state\redis-sentinel\conf\sentinel2\sentinel.conf" -master_port "6379" -hostip $hostip -masterip $hostip
GenerateSentinelConf -sentinel_port "5003" -file ".state\redis-sentinel\conf\sentinel3\sentinel.conf" -master_port "6379" -hostip $hostip -masterip $hostip

# Remove node files to work around IP change
Remove-Item -Path ".state\redis-sentinel\data\node1\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path ".state\redis-sentinel\data\node2\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path ".state\redis-sentinel\data\node3\*" -Force -Recurse -ErrorAction SilentlyContinue
