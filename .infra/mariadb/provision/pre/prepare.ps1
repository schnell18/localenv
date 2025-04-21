# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\mariadb\data")) {
    New-Item -Path ".state\mariadb\data" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\mariadb\conf")) {
    New-Item -Path ".state\mariadb\conf" -ItemType Directory -Force | Out-Null
}

# copy config files to .state to set
if (-not (Test-Path ".state\mariadb\conf\my.cnf")) {
    Copy-Item -Path ".\.infra\mariadb\provision\conf.d\my.cnf" -Destination ".\.state\mariadb\conf" -Recurse
    Set-ItemProperty -Path ".\.state\mariadb\conf\my.cnf" -Name IsReadOnly $true
}

if (-not (Test-Path ".state\mariadb\conf\root.ini")) {
    Copy-Item -Path ".\.infra\mariadb\provision\conf.d\root.ini" -Destination ".\.state\mariadb\conf" -Recurse
    Set-ItemProperty -Path ".\.state\mariadb\conf\root.ini" -Name IsReadOnly $true
}

if (-not (Test-Path ".state\mariadb\conf\appuser.ini")) {
    Copy-Item -Path ".\.infra\mariadb\provision\conf.d\appuser.ini" -Destination ".\.state\mariadb\conf" -Recurse
    Set-ItemProperty -Path ".\.state\mariadb\conf\appuser.ini" -Name IsReadOnly $true
}

