# Import global functions
. ".\.infra\global\libs\functions.ps1"

# Create CockroachDB data directory if it doesn't exist
if (-not (Test-Path ".state\cockroachdb\data")) {
    New-Item -Path ".state\cockroachdb\data" -ItemType Directory -Force | Out-Null
    Write-Host "Created CockroachDB data directory."
}

