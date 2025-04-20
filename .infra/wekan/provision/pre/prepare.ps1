# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\wekan\data")) {
    New-Item -Path ".state\wekan\data" -ItemType Directory -Force | Out-Null
}
