# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\postgresql\data")) {
    New-Item -Path ".state\postgresql\data" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\postgresql\conf")) {
    New-Item -Path ".state\postgresql\conf" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\postgresql\pgadmin")) {
    New-Item -Path ".state\postgresql\pgadmin" -ItemType Directory -Force | Out-Null
}

# copy config files to .state to set
if (-not (Test-Path ".state\postgresql\conf\postgresql.conf")) {
    Copy-Item -Path ".\.infra\postgresql\provision\conf.d\postgresql.conf" -Destination ".\.state\postgresql\conf" -Recurse
    Set-ItemProperty -Path ".\.state\postgresql\conf\postgresql.conf" -Name IsReadOnly $true
}

if (-not (Test-Path ".state\postgresql\conf\pg_hba.conf")) {
    Copy-Item -Path ".\.infra\postgresql\provision\conf.d\pg_hba.conf" -Destination ".\.state\postgresql\conf" -Recurse
    Set-ItemProperty -Path ".\.state\postgresql\conf\pg_hba.conf" -Name IsReadOnly $true
}