# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\rabbitmq")) {
    New-Item -Path ".state\rabbitmq" -ItemType Directory -Force | Out-Null
}
