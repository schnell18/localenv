# Import global functions
. ".\.infra\global\libs\functions.ps1"

# Create and setup zk1 directories
if (-not (Test-Path ".state\zookeeper\zk1\logs")) {
    $null = New-Item -Path ".state\zookeeper\zk1\logs" -ItemType Directory -Force
}

if (-not (Test-Path ".state\zookeeper\zk1\data")) {
    $null = New-Item -Path ".state\zookeeper\zk1\data" -ItemType Directory -Force
    "1" | Set-Content -Path ".state\zookeeper\zk1\data\myid"
}

# Create and setup zk2 directories
if (-not (Test-Path ".state\zookeeper\zk2\logs")) {
    $null = New-Item -Path ".state\zookeeper\zk2\logs" -ItemType Directory -Force
}

if (-not (Test-Path ".state\zookeeper\zk2\data")) {
    $null = New-Item -Path ".state\zookeeper\zk2\data" -ItemType Directory -Force
    "2" | Set-Content -Path ".state\zookeeper\zk2\data\myid"
}

# Create and setup zk3 directories
if (-not (Test-Path ".state\zookeeper\zk3\logs")) {
    $null = New-Item -Path ".state\zookeeper\zk3\logs" -ItemType Directory -Force
}

if (-not (Test-Path ".state\zookeeper\zk3\data")) {
    $null = New-Item -Path ".state\zookeeper\zk3\data" -ItemType Directory -Force
    "3" | Set-Content -Path ".state\zookeeper\zk3\data\myid"
}
