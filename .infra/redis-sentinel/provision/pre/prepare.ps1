# Import global functions (assuming there's a PowerShell equivalent)
# . ".\.infra\global\libs\functions.ps1"

function New-MasterRedisConf {
    param(
        [Parameter(Mandatory=$true)][string]$Port,
        [Parameter(Mandatory=$true)][string]$OutputFile
    )

    (Get-Content ".\.infra\redis-sentinel\provision\redis.conf.tpl") -replace "@REDIS_PORT@", $Port |
        Set-Content -Path $OutputFile
}

function New-SlaveRedisConf {
    param(
        [Parameter(Mandatory=$true)][string]$Port,
        [Parameter(Mandatory=$true)][string]$OutputFile,
        [Parameter(Mandatory=$true)][string]$MasterPort,
        [Parameter(Mandatory=$true)][string]$MasterIp
    )

    (Get-Content ".\.infra\redis-sentinel\provision\redis-slave.conf.tpl") `
        -replace "@REDIS_PORT@", $Port `
        -replace "@MASTER_IP@", $MasterIp `
        -replace "@MASTER_PORT@", $MasterPort |
        Set-Content -Path $OutputFile
}

function New-SentinelConf {
    param(
        [Parameter(Mandatory=$true)][string]$SentinelPort,
        [Parameter(Mandatory=$true)][string]$OutputFile,
        [Parameter(Mandatory=$true)][string]$MasterPort,
        [Parameter(Mandatory=$true)][string]$HostIp,
        [Parameter(Mandatory=$true)][string]$MasterIp
    )

    (Get-Content ".\.infra\redis-sentinel\provision\sentinel.conf.tpl") `
        -replace "@SENTINEL_PORT@", $SentinelPort `
        -replace "@MASTER_IP@", $MasterIp `
        -replace "@MASTER_PORT@", $MasterPort `
        -replace "@SENTINEL_ANNOUNCE_IP@", $HostIp |
        Set-Content -Path $OutputFile
}

# Create data directories if they don't exist
if (-not (Test-Path ".state\redis-sentinel\data")) {
    New-Item -Path ".state\redis-sentinel\data\node1" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\data\node2" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\data\node3" -ItemType Directory -Force | Out-Null
    Write-Host "Created Redis Sentinel data directories."
}

# Create config directories if they don't exist
if (-not (Test-Path ".state\redis-sentinel\conf")) {
    New-Item -Path ".state\redis-sentinel\conf\node1" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\conf\node2" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\conf\node3" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\conf\sentinel1" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\conf\sentinel2" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-sentinel\conf\sentinel3" -ItemType Directory -Force | Out-Null
    Write-Host "Created Redis Sentinel config directories."
}

# Generate Redis config files and use host IP
Write-Host "Generating Redis Sentinel configuration files..."
New-MasterRedisConf -Port "6379" -OutputFile ".state\redis-sentinel\conf\node1\redis.conf"

$hostIp = Get-HostIP
New-SlaveRedisConf -Port "6380" -OutputFile ".state\redis-sentinel\conf\node2\redis.conf" -MasterPort "6379" -MasterIp $hostIp
New-SlaveRedisConf -Port "6381" -OutputFile ".state\redis-sentinel\conf\node3\redis.conf" -MasterPort "6379" -MasterIp $hostIp

New-SentinelConf -SentinelPort "5001" -OutputFile ".state\redis-sentinel\conf\sentinel1\sentinel.conf" -MasterPort "6379" -HostIp $hostIp -MasterIp $hostIp
New-SentinelConf -SentinelPort "5002" -OutputFile ".state\redis-sentinel\conf\sentinel2\sentinel.conf" -MasterPort "6379" -HostIp $hostIp -MasterIp $hostIp
New-SentinelConf -SentinelPort "5003" -OutputFile ".state\redis-sentinel\conf\sentinel3\sentinel.conf" -MasterPort "6379" -HostIp $hostIp -MasterIp $hostIp

# Remove node files to work around IP change
Write-Host "Cleaning up node data files..."
Remove-Item -Path ".state\redis-sentinel\data\node1\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path ".state\redis-sentinel\data\node2\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path ".state\redis-sentinel\data\node3\*" -Force -Recurse -ErrorAction SilentlyContinue
