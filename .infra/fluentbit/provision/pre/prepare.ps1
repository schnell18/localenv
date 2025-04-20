# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\fluentbit\logs-vol")) {
    New-Item -Path ".state\fluentbit\logs-vol" -ItemType Directory -Force | Out-Null
}
