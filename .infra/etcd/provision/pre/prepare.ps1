# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\fluentbit\logs-vol")) {
    New-Item -Path ".state\fluentbit\logs-vol" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\etcd\etcd1\logs")) {
    New-Item -Path ".state\etcd\etcd1\logs" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\etcd\etcd1\data")) {
    New-Item -Path ".state\etcd\etcd1\data" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\etcd\etcd2\logs")) {
    New-Item -Path ".state\etcd\etcd2\logs" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\etcd\etcd2\data")) {
    New-Item -Path ".state\etcd\etcd2\data" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\etcd\etcd3\logs")) {
    New-Item -Path ".state\etcd\etcd3\logs" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\etcd\etcd3\data")) {
    New-Item -Path ".state\etcd\etcd3\data" -ItemType Directory -Force | Out-Null
}
