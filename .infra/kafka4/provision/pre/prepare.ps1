# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

function Create-Kafka-Node-Dirs {
    param(
        [int]$node_id
    )

    # Create directories for Kafka node
    if (-not (Test-Path ".state\kafka4\node$node_id\conf")) {
        $null = New-Item -Path ".state\kafka4\node$node_id\conf" -ItemType Directory -Force
    }

    if (-not (Test-Path ".state\kafka4\node$node_id\logs")) {
        $null = New-Item -Path ".state\kafka4\node$node_id\logs" -ItemType Directory -Force
    }

    if (-not (Test-Path ".state\kafka4\node$node_id\data")) {
        $null = New-Item -Path ".state\kafka4\node$node_id\data" -ItemType Directory -Force
    }
}
function Generate-Kafka-Conf {
    param(
        [int]$node_id,
        [string]$file
    )

    $port = $node_id * 10000 + 9092

    $hostip = Get-HostIP

    (Get-Content ".\.infra\kafka4\provision\server.properties.tpl") -replace "@KAFKA_ADV_HOST_PORT@", "$hostip`:$port" -replace "@NODE_ID@", $node_id |
        Set-Content -Path $file
}


# Create Kafka dirs and generate Kafka config files for all nodes
1..3 | ForEach-Object {
    $node_id = $_
    Create-Kafka-Node-Dirs -node_id $node_id
    Generate-Kafka-Conf -node_id $node_id -file ".state\kafka4\node$node_id\conf\server.properties"
}
