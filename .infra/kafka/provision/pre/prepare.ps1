# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

function Create-Kafka-Node-Dirs {
    param(
        [int]$node_id
    )

    # Create directories for Kafka node
    if (-not (Test-Path ".state\kafka\node$node_id\conf")) {
        $null = New-Item -Path ".state\kafka\node$node_id\conf" -ItemType Directory -Force
    }

    if (-not (Test-Path ".state\kafka\node$node_id\logs")) {
        $null = New-Item -Path ".state\kafka\node$node_id\logs" -ItemType Directory -Force
    }

    if (-not (Test-Path ".state\kafka\node$node_id\data")) {
        $null = New-Item -Path ".state\kafka\node$node_id\data" -ItemType Directory -Force
    }
}

# Create Kafka dirs and generate Kafka config files for all nodes
1..3 | ForEach-Object {
    $node_id = $_
    Create-Kafka-Node-Dirs -node_id $node_id
}
