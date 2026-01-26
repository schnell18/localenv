# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

# Create PostgreSQL data directory if it doesn't exist
if (-not (Test-Path ".state\postgresql\data")) {
    New-Item -Path ".state\postgresql\data" -ItemType Directory -Force | Out-Null
    Write-Host "Created PostgreSQL data directory."
}

# Create PostgreSQL config directory if it doesn't exist
if (-not (Test-Path ".state\postgresql\conf")) {
    New-Item -Path ".state\postgresql\conf" -ItemType Directory -Force | Out-Null
    Write-Host "Created PostgreSQL config directory."
}

# Create pgAdmin directory if it doesn't exist
if (-not (Test-Path ".state\postgresql\pgadmin")) {
    New-Item -Path ".state\postgresql\pgadmin" -ItemType Directory -Force | Out-Null
    Write-Host "Created pgAdmin directory."
}

# Copy config files from provision/conf.d to .state/postgresql/conf
$sourceConfPath = ".\.infra\postgresql\provision\conf.d\*"
if (Test-Path $sourceConfPath) {
    Copy-Item -Path $sourceConfPath -Destination ".\.state\postgresql\conf" -Force
    Write-Host "Copied PostgreSQL configuration files."
}
