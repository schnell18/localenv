# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

function New-BrokerConf {
    param (
        [Parameter(Mandatory=$true)][string]$Broker,
        [Parameter(Mandatory=$true)][string]$OutputFile
    )

    # Copy the broker configuration template
    Get-Content ".\.infra\rocketmq\provision\$Broker\conf\broker.conf" | Set-Content -Path $OutputFile

    # Append the host IP to the configuration
    "brokerIP1=$(Get-HostIP)" | Add-Content -Path $OutputFile
}

# Create directory structure for namesrv logs
if (-not (Test-Path ".state\rocketmq\namesrv\logs")) {
    New-Item -Path ".state\rocketmq\namesrv\logs" -ItemType Directory -Force | Out-Null
}

# Create directory structure for broker1 configuration
if (-not (Test-Path ".state\rocketmq\broker1\conf")) {
    New-Item -Path ".state\rocketmq\broker1\conf" -ItemType Directory -Force | Out-Null

    # Check if broker.conf exists as a directory and remove it if needed
    if (Test-Path ".state\rocketmq\broker1\conf\broker.conf" -PathType Container) {
        Remove-Item ".state\rocketmq\broker1\conf\broker.conf" -Recurse -Force
    }
}

# Generate broker config file with host IP
$broker1ConfPath = ".state\rocketmq\broker1\conf\broker.conf"
if (-not (Test-Path $broker1ConfPath)) {
    New-Item -Path $broker1ConfPath -ItemType File -Force | Out-Null
}
New-BrokerConf -Broker "broker1" -OutputFile $broker1ConfPath

# Create directory structure for broker1 logs
if (-not (Test-Path ".state\rocketmq\broker1\logs")) {
    New-Item -Path ".state\rocketmq\broker1\logs" -ItemType Directory -Force | Out-Null
}

# Create directory structure for broker1 store/commitLog
if (-not (Test-Path ".state\rocketmq\broker1\store\commitLog")) {
    New-Item -Path ".state\rocketmq\broker1\store\commitLog" -ItemType Directory -Force | Out-Null
}

# Create directory structure for broker1 store/consumequeue
if (-not (Test-Path ".state\rocketmq\broker1\store\consumequeue")) {
    New-Item -Path ".state\rocketmq\broker1\store\consumequeue" -ItemType Directory -Force | Out-Null
}

# Create directory structure for broker2 logs
if (-not (Test-Path ".state\rocketmq\broker2\logs")) {
    New-Item -Path ".state\rocketmq\broker2\logs" -ItemType Directory -Force | Out-Null
}

# Create directory structure for broker2 store/commitLog
if (-not (Test-Path ".state\rocketmq\broker2\store\commitLog")) {
    New-Item -Path ".state\rocketmq\broker2\store\commitLog" -ItemType Directory -Force | Out-Null
}

# Create directory structure for broker2 store/consumequeue
if (-not (Test-Path ".state\rocketmq\broker2\store\consumequeue")) {
    New-Item -Path ".state\rocketmq\broker2\store\consumequeue" -ItemType Directory -Force | Out-Null
}

# Create directory structure for dashboard logs
if (-not (Test-Path ".state\rocketmq\dashboard\logs")) {
    New-Item -Path ".state\rocketmq\dashboard\logs" -ItemType Directory -Force | Out-Null
}

# Create directory structure for dashboard data
if (-not (Test-Path ".state\rocketmq\dashboard\data")) {
    New-Item -Path ".state\rocketmq\dashboard\data" -ItemType Directory -Force | Out-Null
}
