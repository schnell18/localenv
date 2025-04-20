# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\mongodb\data")) {
    New-Item -Path ".state\mongodb\data" -ItemType Directory -Force | Out-Null
}

