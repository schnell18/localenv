# Import library functions
. ".\.infra\global\libs\functions.ps1"
. ".\.infra\global\libs\libinfractl.ps1"

# Get command argument
$cmd = $args[0]
if ([string]::IsNullOrEmpty($cmd)) {
    Show-Usage
    exit 1
}

# Get remaining arguments
$cmdArgs = $args[1..$args.Count]

# Process commands
switch ($cmd) {
    "start"      { Start-Infra $cmdArgs }
    "stop"       { Stop-Infra $cmdArgs }
    "status"     { Get-Status $cmdArgs }
    "attach"     { Attach-Container $cmdArgs }
    "list"       { Get-InfraList }
    "init"       { Initialize-Environment }
    "destroy"    { Destroy-Environment }
    "logs"       { Show-Logs $cmdArgs }
    "webui"      { Start-WebUi $cmdArgs }
    "refresh-db" { Refresh-InfraDb $cmdArgs }
    default      { Show-Usage; exit 1 }
}
