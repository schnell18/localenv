# Import global functions (assuming there's a PowerShell equivalent)
# . ".\.infra\global\libs\functions.ps1"

# Create directories for Kafka node1
if (-not (Test-Path ".state\kafka4\node1\conf")) {
    New-Item -Path ".state\kafka4\node1\conf" -ItemType Directory -Force
}

if (-not (Test-Path ".state\kafka4\node1\logs")) {
    New-Item -Path ".state\kafka4\node1\logs" -ItemType Directory -Force
}

if (-not (Test-Path ".state\kafka4\node1\data")) {
    New-Item -Path ".state\kafka4\node1\data" -ItemType Directory -Force
}

# Create directories for Kafka node2
if (-not (Test-Path ".state\kafka4\node2\conf")) {
    New-Item -Path ".state\kafka4\node2\conf" -ItemType Directory -Force
}

if (-not (Test-Path ".state\kafka4\node2\logs")) {
    New-Item -Path ".state\kafka4\node2\logs" -ItemType Directory -Force
}

if (-not (Test-Path ".state\kafka4\node2\data")) {
    New-Item -Path ".state\kafka4\node2\data" -ItemType Directory -Force
}

# Create directories for Kafka node3
if (-not (Test-Path ".state\kafka4\node3\conf")) {
    New-Item -Path ".state\kafka4\node3\conf" -ItemType Directory -Force
}

if (-not (Test-Path ".state\kafka4\node3\logs")) {
    New-Item -Path ".state\kafka4\node3\logs" -ItemType Directory -Force
}

if (-not (Test-Path ".state\kafka4\node3\data")) {
    New-Item -Path ".state\kafka4\node3\data" -ItemType Directory -Force
}

function GenerateKafkaConf {
    param(
        [int]$node_id,
        [string]$file
    )

    $port = $node_id * 10000 + 9092

    # GetHostIP function - replace with actual implementation from your functions file
    function GetHostIP {
        return (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet | Where-Object {$_.IPAddress -notlike "127.*"}).IPAddress
    }

    $hostip = GetHostIP

    (Get-Content ".\.infra\kafka4\provision\server.properties.tpl") -replace "@KAFKA_ADV_HOST_PORT@", "$hostip`:$port" -replace "@NODE_ID@", $node_id |
        Set-Content -Path $file
}

# Generate Kafka config files for all nodes
1..3 | ForEach-Object {
    $node_id = $_
    GenerateKafkaConf -node_id $node_id -file ".state\kafka4\node$node_id\conf\server.properties"
}
