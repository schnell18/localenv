# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

if (-not (Test-Path ".state\kafka\broker1\logs")) {
    New-Item -Path ".state\kafka\broker1\logs" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\kafka\broker1\data")) {
    New-Item -Path ".state\kafka\broker1\data" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\kafka\broker2\logs")) {
    New-Item -Path ".state\kafka\broker2\logs" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\kafka\broker2\data")) {
    New-Item -Path ".state\kafka\broker2\data" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\kafka\broker3\logs")) {
    New-Item -Path ".state\kafka\broker3\logs" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path ".state\kafka\broker3\data")) {
    New-Item -Path ".state\kafka\broker3\data" -ItemType Directory -Force | Out-Null
}


