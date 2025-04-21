# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

function New-RedisConf {
    param (
        [Parameter(Mandatory=$true)][string]$Port,
        [Parameter(Mandatory=$true)][string]$OutputFile
    )

    $hostIp = Get-HostIP

    Get-Content ".\.infra\redis-cluster\provision\redis.conf.tpl" |
        ForEach-Object {
            $_ -replace '@REDIS_PORT@', $Port -replace '@CLUSTER_ANNOUNCE_IP@', $hostIp
        } |
        Set-Content -Path $OutputFile
}

function New-RedisClusterScript {
    param (
        [Parameter(Mandatory=$true)][string]$Port1,
        [Parameter(Mandatory=$true)][string]$Port2,
        [Parameter(Mandatory=$true)][string]$Port3,
        [Parameter(Mandatory=$true)][string]$OutputFile
    )

    $hostIp = Get-HostIP

    ((Get-Content ".\.infra\redis-cluster\provision\create-cluster.sh.tpl") -join "`n") + "`n" |
        ForEach-Object {
            $_ -replace '@REDIS_PORT1@', $Port1 `
              -replace '@REDIS_PORT2@', $Port2 `
              -replace '@REDIS_PORT3@', $Port3 `
              -replace '@CLUSTER_ANNOUNCE_IP@', $hostIp
        } |
        Set-Content -NoNewline -Path $OutputFile
}

# Create data directories for each node
if (-not (Test-Path ".state\redis-cluster\data")) {
    New-Item -Path ".state\redis-cluster\data\node1" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-cluster\data\node2" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-cluster\data\node3" -ItemType Directory -Force | Out-Null
}

# Create config directories for each node
if (-not (Test-Path ".state\redis-cluster\conf")) {
    New-Item -Path ".state\redis-cluster\conf\node1" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-cluster\conf\node2" -ItemType Directory -Force | Out-Null
    New-Item -Path ".state\redis-cluster\conf\node3" -ItemType Directory -Force | Out-Null
}

# Generate Redis config files for each node with the appropriate port and host IP
New-RedisConf -Port "7001" -OutputFile ".state\redis-cluster\conf\node1\redis.conf"
New-RedisConf -Port "7002" -OutputFile ".state\redis-cluster\conf\node2\redis.conf"
New-RedisConf -Port "7003" -OutputFile ".state\redis-cluster\conf\node3\redis.conf"

# Create bin directory if it doesn't exist
if (-not (Test-Path ".state\redis-cluster\bin")) {
    New-Item -Path ".state\redis-cluster\bin" -ItemType Directory -Force | Out-Null
}

# Remove node data files to work around IP changes
if (Test-Path ".state\redis-cluster\data\node1") {
    Remove-Item ".state\redis-cluster\data\node1\*" -Force -Recurse -ErrorAction SilentlyContinue
}
if (Test-Path ".state\redis-cluster\data\node2") {
    Remove-Item ".state\redis-cluster\data\node2\*" -Force -Recurse -ErrorAction SilentlyContinue
}
if (Test-Path ".state\redis-cluster\data\node3") {
    Remove-Item ".state\redis-cluster\data\node3\*" -Force -Recurse -ErrorAction SilentlyContinue
}

# Create and set permissions for the cluster creation script
$clusterScriptPath = ".state\redis-cluster\bin\create-cluster.sh"
if (-not (Test-Path $clusterScriptPath)) {
    New-Item -Path $clusterScriptPath -ItemType File -Force | Out-Null
}

# In Windows, we need a different approach to make files executable
# We'll create the file with the content, but note that execution permissions work differently
New-RedisClusterScript -Port1 "7001" -Port2 "7002" -Port3 "7003" -OutputFile $clusterScriptPath

# Make the script executable (note: this doesn't directly translate to Windows permissions)
# In PowerShell/Windows, you typically don't need to change file permissions to execute scripts
# But we can set ACL if needed
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    # For Windows, we don't need chmod equivalent, but we can set it to be executable if needed
    # This is just a placeholder - Windows handles script execution differently
} else {
    # If running in PowerShell Core on Unix-like systems
    if (Get-Command "chmod" -ErrorAction SilentlyContinue) {
        & chmod +x $clusterScriptPath
    }
}
