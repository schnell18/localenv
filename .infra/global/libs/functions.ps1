function Get-HostIP {
    $os = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" }
          elseif ($IsMacOS) { "Darwin" }
          elseif ($IsLinux) { "Linux" }
          else { "Unknown" }

    switch ($os) {
        "Darwin" {
            & ipconfig getifaddr en0
        }
        "Linux" {
            $output = & ip route get 8.8.8.8 | Select-Object -First 1
            if ($output -match '\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s') {
                return $Matches[1]
            }
        }
        "Windows" {
            # Get the IP address of the primary network adapter
            $ipAddress = Get-NetIPAddress |
                Where-Object {
                    $_.AddressFamily -eq 'IPv4' -and
                    $_.PrefixOrigin -eq 'Dhcp' -and
                    $_.SuffixOrigin -eq 'Dhcp'
                } |
                Select-Object -First 1 -ExpandProperty IPAddress

            return $ipAddress
        }
        default {
            return ""
        }
    }
}

function Get-DatabaseStatus {
    param (
        [Parameter(Mandatory=$true)][string]$Container,
        [Parameter(Mandatory=$true)][string]$DbType
    )

    $port = Get-DatabasePort -DbType $DbType

    if ($DbType -eq "TiDB") {
        & podman exec $Container sh -c "echo select 'running' | mysql -N -h 127.0.0.1 -P $port -u root" 2>$null
    } else {
        & podman exec $Container sh -c "echo select 'running' | mysql -N -h 127.0.0.1 -P $port -u root -proot" 2>$null
    }
}

function Wait-DatabaseReady {
    $databaseReady = 0
    $dbContainer = & podman ps -f label=database=true -q

    if ([string]::IsNullOrEmpty($dbContainer)) {
        Write-Host "Database is not ready..."
        return 0
    }

    $dbType = & podman inspect -f "{{.Config.Labels.dbtype}}" $dbContainer
    Write-Host "Checking $dbType readiness" -NoNewline

    for ($attempt = 1; $attempt -le 20; $attempt++) {
        Write-Host "." -NoNewline
        $stat = Get-DatabaseStatus -Container $dbContainer -DbType $dbType

        if ($stat -like "*running*") {
            Write-Host ""
            Write-Host "$dbType is ready!"
            $databaseReady = 1
            break
        }

        Start-Sleep -Seconds 1
    }

    return $databaseReady
}

function Get-DatabasePort {
    param (
        [Parameter(Mandatory=$true)][string]$DbType
    )

    switch ($DbType) {
        "TiDB" { return "4000" }
        "MariaDB" { return "3306" }
        default { return "3306" }
    }
}

function Refresh-InfraDb {
    param (
        [Parameter(Mandatory=$true)][string]$DbContainer,
        [Parameter(Mandatory=$true)][string[]]$Infrastructures
    )

    $basedir = Get-Location

    foreach ($infra in $Infrastructures) {
        $originalLocation = Get-Location
        Set-Location "$basedir\.infra\$infra\provision"

        if (Test-Path "schema\schema.sql") {
            $content = Get-Content -Path "schema\schema.sql" -TotalCount 1

            if ($content -match "USE\s+(\w+);") {
                $db = $Matches[1]
            } else {
                $tokens = $content -split ' '
                if ($tokens.Count -ge 2) {
                    $db = $tokens[1] -replace ';',''
                }
            }

            Write-Host "Prepare database ${db} for infra $(Split-Path -Leaf $infra)..."
            & podman exec -it ${DbContainer} /bin/sh /setup/create-database.sh $db mfg

            Write-Host "Loading schema and data using podman for project $(Split-Path -Leaf $infra)..."
            & podman exec -it ${DbContainer} /bin/sh /setup/load-schema-and-data.sh $(Split-Path -Leaf $infra) mfg $db .infra
        }

        Set-Location $originalLocation
    }
}

function Set-JobScheduler {
    param (
        [Parameter(Mandatory=$true)][string]$App,
        [Parameter(Mandatory=$true)][string]$Pass
    )

    # Check if job scheduler is running
    $jobSchedulerContainer = & podman ps -f label=job_scheduler=true -q

    if ([string]::IsNullOrEmpty($jobSchedulerContainer)) {
        Write-Host "Job scheduler is not running, skip app registration"
        return
    }

    $exist = Invoke-RestMethod -Uri "http://127.0.0.1:7700/appInfo/list?condition=${App}" |
        Select-Object -ExpandProperty data |
        Where-Object { $_.appName -eq $App } |
        Select-Object -ExpandProperty appName -ErrorAction SilentlyContinue

    if ($exist -ne $App) {
        Write-Host "Setup PowerJob app $App ..." -NoNewline

        $body = @{
            appName = $App
            password = $Pass
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7700/appInfo/save" `
            -ContentType "application/json" -Body $body

        if ($response.success) {
            Write-Host "OK"
        } else {
            Write-Host "FAILED"
        }
    }
}

function Import-ConfigIntoNacos {
    param (
        [Parameter(Mandatory=$true)][string]$ConfigFile,
        [Parameter(Mandatory=$true)][string]$DataId
    )

    $content = Get-Content -Path $ConfigFile -Raw
    $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $hexContent = [BitConverter]::ToString($contentBytes) -replace '-', '%'

    $parameters = @{
        tenant = "dev"
        dataId = $DataId
        group = "DEFAULT_GROUP"
        type = "yaml"
        content = $hexContent
    }

    Invoke-RestMethod -Method Post -Uri "http://nacos:8848/nacos/v1/cs/configs" -Body $parameters | Out-Null
}

function Open-Browser {
    param (
        [Parameter(Mandatory=$true)][string]$Url
    )

    $os = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" }
          elseif ($IsMacOS) { "Darwin" }
          elseif ($IsLinux) { "Linux" }
          else { "Unknown" }

    switch ($os) {
        "Darwin" { & open $Url }
        "Linux" { & xdg-open $Url }
        "Windows" { Start-Process $Url }
        default { Write-Host "Unsupported OS: $os" }
    }
}

function Test-DatabaseExists {
    param (
        [Parameter(Mandatory=$true)][string]$Container,
        [Parameter(Mandatory=$true)][string]$DbType,
        [Parameter(Mandatory=$true)][string]$Database
    )

    $port = Get-DatabasePort -DbType $DbType
    $result = "true"

    if ($DbType -eq "TiDB") {
        $ret = & podman exec $Container sh -c "echo show databases | mysql -N -h 127.0.0.1 -P $port -u root | grep $Database" 2>$null
        if ([string]::IsNullOrEmpty($ret)) {
            $result = "false"
        }
    } else {
        $ret = & podman exec $Container sh -c "echo show databases | mysql -N -h 127.0.0.1 -P $port -u root -proot | grep $Database" 2>$null
        if ([string]::IsNullOrEmpty($ret)) {
            $result = "false"
        }
    }

    return $result
}

function Set-Topic {
    param (
        [Parameter(Mandatory=$true)][string[]]$Topics
    )

    # Check if broker is running
    $mqBrokerContainer = & podman ps -f label=mq_broker=true -q

    if ([string]::IsNullOrEmpty($mqBrokerContainer)) {
        Write-Host "RocketMQ broker is not running, skip topic creation"
        return
    }

    foreach ($topic in $Topics) {
        Write-Host "Setup RocketMQ topic $topic ..."
        & podman exec -it ${mqBrokerContainer} `
            sh /home/rocketmq/rocketmq-4.9.2/bin/mqadmin updateTopic `
            -c devCluster -t $topic -w 4 -r 4 > $null
    }
}

function Get-DescriptorFilePaths {
    param (
        [Parameter(Mandatory=$true)][string[]]$Infrastructures
    )

    $composeFiles = ""

    if ($Infrastructures[0] -eq "all") {
        $files = Get-ChildItem -Path ".infra\*\descriptor.yml"
        foreach ($file in $files) {
            $composeFiles = "$composeFiles -f $(Get-Location)\$($file.FullName)"
        }
    } else {
        foreach ($infra in $Infrastructures) {
            $composeFiles = "$composeFiles -f $(Get-Location)\.infra\${infra}\descriptor.yml"
        }
    }

    return $composeFiles
}
