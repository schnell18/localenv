# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\filebeat\logs-vol")) {
    New-Item -Path ".state\filebeat\logs-vol" -ItemType Directory -Force | Out-Null
}

