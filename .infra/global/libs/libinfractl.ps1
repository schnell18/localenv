function Show-Usage {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.ps1 start infra1 [infra2 infra3 ...]
                 stop all | infra1 [infra2 infra3 ...]
                 status all | infra1 [infra2 infra3 ...]
                 refresh-db infra1 [infra2 infra3 ...]
                 logs infra1 [infra2 infra3 ...]
                 webui infra1 [infra2 infra3 ...]
                 init
                 destroy
                 list
"@
}

function Show-UsageList {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
List available infrastructure database/middleware.
Usage:
    infractl.ps1 list
"@
}

function Show-UsageInit {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Initialize local environment.
Usage:
    infractl.ps1 init
"@
}

function Show-UsageDestroy {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Destroy local environment forcefully.
Usage:
    infractl.ps1 destroy
"@
}

function Show-UsageAttach {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Attach to running infra and get a login shell.
Usage:
    infractl.ps1 attach infra
"@
}

function Show-UsageLogs {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command continuously shows logs from specified infra.
Usage:
    infractl.ps1 logs infra1 [infra2 infra3 ...]
"@
}

function Show-UsageRefreshDb {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.ps1 refresh-db infra1 [infra2 infra3 ...]
"@
}

function Show-UsageStart {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.ps1 start infra1 [infra2 infra3 ...]
"@
}

function Show-UsageStatus {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.ps1 status all | infra1 [infra2 infra3 ...]
"@
}

function Show-UsageWebui {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Launch webui of specified infrastructures.
Usage:
    infractl.ps1 webui infra1 [infra2 infra3 ...]
"@
}

function Show-UsageStop {
    Write-Host @"
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.ps1 stop infra1 [infra2 infra3 ...]
"@
}

function Get-DescriptorFilePaths {
    param (
        [string[]]$Profiles
    )

    $composeFiles = ""
    foreach ($profile in $Profiles) {
        $composeFiles += " -f $(Get-Location)\.infra\${profile}\descriptor.yml"
    }

    return $composeFiles
}

function Get-Status {
    param (
        [string]$Infra
    )

    $CurrentProfilesStatFile = ".state\compose-files.txt"
    $composeFiles = ""

    if (Test-Path $CurrentProfilesStatFile) {
        $composeFiles = Get-Content $CurrentProfilesStatFile
    } else {
        if ([string]::IsNullOrEmpty($Infra)) {
            Show-UsageStatus
            exit 1
        }
        $composeFiles = Get-DescriptorFilePaths $Infra
    }

    Start-Process "python" `
        -NoNewWindow `
        -ArgumentList "bin\podman_compose.py $composeFiles ps" `
        -Wait
}

function Stop-Infra {
    param (
        [string]$Infra
    )

    $CurrentProfilesStatFile = ".state\compose-files.txt"
    $CurrentActiveInfras = ".state\active-infras.txt"
    $composeFiles = ""

    if (Test-Path $CurrentProfilesStatFile) {
        $composeFiles = Get-Content $CurrentProfilesStatFile
        Start-Process "python" `
            -NoNewWindow `
            -ArgumentList "bin\podman_compose.py $composeFiles down" `
            -Wait
        # Remove profile stat files to cleanup
        if (Test-Path $CurrentProfilesStatFile) {
            Remove-Item -Path $CurrentProfilesStatFile -Force
        }
        if (Test-Path $CurrentActiveInfras) {
            Remove-Item -Path $CurrentActiveInfras -Force
        }
    } else {
        if ([string]::IsNullOrEmpty($Infra)) {
            Show-UsageStop
            exit 1
        }
        $composeFiles = Get-DescriptorFilePaths $Infra
        Start-Process "python" `
            -NoNewWindow `
            -ArgumentList "bin\podman_compose.py $composeFiles down" `
            -Wait
    }
}

function Get-InfraList {
    $infraFiles = Get-ChildItem -Path ".infra\*\descriptor.yml" -ErrorAction SilentlyContinue
    foreach ($file in $infraFiles) {
        $parent = Split-Path -Path (Split-Path -Path $file -Parent) -Leaf
        Write-Host $parent
    }
}

function Initialize-Environment {
    # For Windows
    & podman machine init localenv --memory 6144 --rootful -v ${env:HOME}:${env:HOME}:rw,security_model=mapped-xattr --now
    & podman machine ssh --username root localenv rpm-ostree install qemu-user-static
    & podman machine stop localenv
    & podman machine start localenv
    & podman system connection default localenv-root
}

function Destroy-Environment {
    # For Windows
    & podman machine rm localenv --force
}

function Open-Browser {
    param (
        [string]$Url
    )

    Start-Process $Url
}

function Start-WebUi {
    param (
        [string[]]$Infrastructures
    )

    if ($Infrastructures.Length -eq 0) {
        Show-UsageWebui
        exit 1
    }

    # Do infra-specific post setup
    foreach ($infra in $Infrastructures) {
        $webuiScript = ".infra\$infra\provision\post\webui.txt"
        if (Test-Path $webuiScript) {
            Write-Host "Launch webui for $infra..."
            $url = Get-Content $webuiScript
            if (![string]::IsNullOrEmpty($url)) {
                Open-Browser $url
            }
        }

    }
}

function Start-Infra {
    param (
        [string[]]$Infrastructures
    )

    if ($Infrastructures.Length -eq 0) {
        Show-UsageStart
        exit 1
    }

    # Make state directories exist
    if (!(Test-Path ".state")) {
        New-Item -Path ".state" -ItemType Directory | Out-Null
    }

    $composeFiles = ""
    $activeInfras = ""

    foreach ($infra in $Infrastructures) {
        $prepareScript = ".infra\$infra\provision\pre\prepare.ps1"
        if (Test-Path $prepareScript) {
            Write-Host "Run prepare script for $infra..."
            & $prepareScript
        }
        $composeFiles += " -f $(Get-Location)\.infra\${infra}\descriptor.yml"
        $activeInfras += " $infra"
    }

    $composeFiles | Out-File -FilePath ".state\compose-files.txt"
    $activeInfras | Out-File -FilePath ".state\active-infras.txt"

    # Start containers managed by podman
    Start-Process "python" `
        -NoNewWindow `
        -ArgumentList "bin\podman_compose.py $composeFiles up -d --force-recreate" `
        -Wait

    # Do infra-specific post setup
    foreach ($infra in $Infrastructures) {
        $setupScript = ".infra\$infra\provision\post\setup.ps1"
        if (Test-Path $setupScript) {
            Write-Host "Run post setup script for $infra..."
            & $setupScript
        }
    }

    foreach ($infra in $Infrastructures) {
        $webuiScript = ".infra\$infra\provision\post\webui.txt"
        if (Test-Path $webuiScript) {
            Write-Host "Launch webui for $infra..."
            $url = Get-Content $webuiScript
            if (![string]::IsNullOrEmpty($url)) {
                Open-Browser $url
            }
        }
    }
}

function Attach-Container {
    param (
        [string]$ContainerName
    )

    if ([string]::IsNullOrEmpty($ContainerName)) {
        Show-UsageAttach
        exit 1
    }

    $CurrentProfilesStatFile = ".state\compose-files.txt"
    if (Test-Path $CurrentProfilesStatFile) {
        $composeFiles = Get-Content $CurrentProfilesStatFile
        # & bin\podman-compose $composeFiles exec $ContainerName sh
        Start-Process "python" `
            -NoNewWindow `
            -ArgumentList "bin\podman_compose.py $composeFiles exec $ContainerName sh" `
            -Wait
    }
}

function Refresh-InfraDb {
    param (
        [string[]]$Infrastructures
    )

    if ($Infrastructures.Length -eq 0) {
        Show-UsageRefreshDb
        exit 1
    }

    # This function seems to call another function that wasn't defined in original script
    # We'll assume it would have been part of additional implementation
    Write-Host "Refreshing databases for $($Infrastructures -join ', ')"
    # Implementation would go here
}

function Show-Logs {
    param (
        [string[]]$Infrastructures
    )

    if ($Infrastructures.Length -eq 0) {
        Show-UsageLogs
        exit 1
    }

    $CurrentProfilesStatFile = ".state\compose-files.txt"
    if (Test-Path $CurrentProfilesStatFile) {
        $composeFiles = Get-Content $CurrentProfilesStatFile
        $allInfras = ""
        foreach ($infra in $Infrastructures) {
            $allInfras += " $infra"
        }
        # & bin\podman-compose $composeFiles logs -f $allInfras
        Start-Process "python" `
            -NoNewWindow `
            -ArgumentList "bin\podman_compose.py $composeFiles logs -f $allInfras" `
            -Wait
    }
}
