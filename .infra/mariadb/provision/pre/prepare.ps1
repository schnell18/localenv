# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\mariadb\data")) {
    New-Item -Path ".state\mariadb\data" -ItemType Directory -Force | Out-Null
}

