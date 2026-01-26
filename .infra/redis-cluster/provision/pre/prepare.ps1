# Import functions from the global library
. ".\.infra\global\libs\functions.ps1"

function New-RedisConf {
    param (
        [Parameter(Mandatory=$true)][string]$Port,
        [Parameter(Mandatory=$true)][string]$OutputFile
    )

    $hostIp = Get-HostIP

    Get-Content ".\.infra\redis-cluster\provision\redis.conf.tpl" |
        ForEach-Object {
            $_ -replace '@REDIS_PORT@', $Port -replace '@CLUSTER_ANNOUNCE_IP@', $hostIp
        } |
        Set-Content -Path $OutputFile
}

function New-RedisClusterScript {
    param (
        [Parameter(Mandatory=$true)][string]$Port1,
        [Parameter(Mandatory=$true)][string]$Port2,
        [Parameter(Mandatory=$true)][string]$Port3,
        [Parameter(Mandatory=$true)][string]$OutputFile
    )

    $hostIp = Get-HostIP

    ((Get-Content ".\.infra\redis-cluster\provision\create-cluster.sh.tpl") -join "`n") + "`n" |
        ForEach-Object {
            $_ -replace '@REDIS_PORT1@', $Port1 `
              -replace '@REDIS_PORT2@', $Port2 `
              -replace '@REDIS_PORT3@', $Port3 `
              -replace '@CLUSTER_ANNOUNCE_IP@', $hostIp
        } |
        Set-Content -NoNewline -Path $OutputFile
}

function Get-PreviousHostIP {
    param (
        [Parameter(Mandatory=$true)][string]$MetadataFile
    )

    $content = Get-Content $MetadataFile | Where-Object { $_ -match ":7001" }
    if ($content) {
        $ip = ($content -split ' ')[1] -split ':' | Select-Object -First 1
        return $ip
    }
    return $null
}

function Update-HostIPInMetadata {
    param (
        [Parameter(Mandatory=$true)][string]$MetadataFile,
        [Parameter(Mandatory=$true)][string]$PreviousIP,
        [Parameter(Mandatory=$true)][string]$CurrentIP
    )

    (Get-Content $MetadataFile) -replace [regex]::Escape($PreviousIP), $CurrentIP |
        Set-Content $MetadataFile
}

function Update-ClusterMetadata {
    for ($n = 1; $n -le 3; $n++) {
        $metadataFile = ".state\redis-cluster\data\node$n\nodes.conf"
        if (Test-Path $metadataFile) {
            $currentIP = Get-HostIP
            $previousIP = Get-PreviousHostIP -MetadataFile $metadataFile
            if ($previousIP -and ($currentIP -ne $previousIP)) {
                Write-Host "Updating IP address in $metadataFile from $previousIP to $currentIP"
                Update-HostIPInMetadata -MetadataFile $metadataFile -PreviousIP $previousIP -CurrentIP $currentIP
            }
        }
    }
}

function Setup-Port-Forward-Windows {
    param (
        [string]$RuleName = "Redis Cluster",
        [int[]]$Ports = @(7001, 7002, 7003, 17001, 17002, 17003)
    )

    # --- Check elevation; prompt to elevate if needed ---
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        $response = Read-Host "Setup port forward for Redis-Cluster requires administrator privileges.`nDo you want to run Redis port forward setup in a separate window as Administrator? (Y)`nPress y to confirm, press Ctrl+C to terminate"
        if ($response -match '^[Yy]') {
            Write-Host "Restarting script with administrator privileges..."

            # Get the current working directory to pass to elevated session
            $currentDir = Get-Location

            # Create the elevated command block that sources this script and calls the function
            $cmd = @"
& {
    try {
        Set-Location '$currentDir'
        . '.\.infra\global\libs\functions.ps1'
        . '.\.infra\redis-cluster\provision\pre\prepare.ps1'
        Setup-Port-Forward-Windows
    }
    catch {
        Write-Host "Error: `$(`$_.Exception.Message)" -ForegroundColor Red
        Write-Host `$_.ScriptStackTrace -ForegroundColor Red
    }
    Write-Host "Port forwarding setup completed. Press any key to close this window..."
    `$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
"@

            # Start elevated PowerShell
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass", "-Command $cmd" -Verb RunAs
        } else {
            Write-Host "Operation cancelled. Please rerun with Administrator privileges."
            exit
        }
        return
    }

    # --- Get WSL VM IP ---
    $VM_IP = wsl sh -c "ip -4 addr show eth0 | grep 'inet ' | cut -d/ -f1 | head -n1 | sed -e 's/^\s\+//' | cut -d' ' -f2"
    $VM_IP = $VM_IP.Trim()
    if (-not $VM_IP) {
        Write-Host "Failed to detect WSL IP address. Ensure Fedora is running in WSL."
        return
    }

    Write-Host "Detected WSL IP address: $VM_IP`n"

    # --- Create Port Proxy Rules (only if missing) ---
    foreach ($port in $Ports) {
        $existingRule = netsh interface portproxy show v4tov4 | Select-String "0.0.0.0\s+$port"
        if ($existingRule) {
            Write-Host "Port proxy for port $port already exists -- skipping."
        } else {
            Write-Host "Creating port proxy for port $port => $VM_IP"
            netsh interface portproxy add v4tov4 listenport=$port listenaddress=0.0.0.0 connectport=$port connectaddress=$VM_IP | Out-Null
        }
    }

    # --- Check for Firewall Rule ---
    foreach ($port in $Ports) {
        $fwRule = Get-NetFirewallRule -DisplayName "$RuleName-$port" -ErrorAction SilentlyContinue
        if ($fwRule) {
            Write-Host "Firewall rule '$RuleName-$port' already exists -- skipping."
        } else {
            Write-Host "Creating firewall rule '$RuleName-$port' for Redis Cluster ports..."
            New-NetFirewallRule -DisplayName "$RuleName-$port" `
                -Direction Inbound -LocalPort $port `
                -Protocol TCP -Action Allow | Out-Null
            Write-Host "Firewall rule '$RuleName-$port' created."
        }
    }

    Write-Host "Port forwarding and firewall setup complete."
}


function Setup-Kernel-Params-Windows {
    $podmanScript = @'
sysctl -w vm.overcommit_memory=1
'@

    Write-Host "Configuring kernel parameters for Redis cluster..."
    $podmanScript | & podman machine ssh --username root localenv
}



# Run main section if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    # Patch cluster metadata to handle IP changes (WiFi roaming, etc.)
    Update-ClusterMetadata

    # Create data directories for each node
    # (if they don't exist, they'll be created during patching)
    if (-not (Test-Path ".state\redis-cluster\data")) {
        New-Item -Path ".state\redis-cluster\data\node1" -ItemType Directory -Force | Out-Null
        New-Item -Path ".state\redis-cluster\data\node2" -ItemType Directory -Force | Out-Null
        New-Item -Path ".state\redis-cluster\data\node3" -ItemType Directory -Force | Out-Null
        Write-Host "Created Redis cluster data directories."
    }

    # Create config directories for each node
    if (-not (Test-Path ".state\redis-cluster\conf")) {
        New-Item -Path ".state\redis-cluster\conf\node1" -ItemType Directory -Force | Out-Null
        New-Item -Path ".state\redis-cluster\conf\node2" -ItemType Directory -Force | Out-Null
        New-Item -Path ".state\redis-cluster\conf\node3" -ItemType Directory -Force | Out-Null
        Write-Host "Created Redis cluster config directories."
    }


    # Prepare configuration for p3x-redis-ui
    if (-not (Test-Path ".state\redis-cluster\redis-ui")) {
        New-Item -Path ".state/redis-cluster" -ItemType Directory -Force | Out-Null
        Copy-Item -Path ".infra/redis-cluster/provision/redis-ui" -Destination ".state/redis-cluster/redis-ui" -Recurse -Force
    }

    # Generate Redis config files for each node with the appropriate port and host IP
    Write-Host "Generating Redis configuration files..."
    New-RedisConf -Port "7001" -OutputFile ".state\redis-cluster\conf\node1\redis.conf"
    New-RedisConf -Port "7002" -OutputFile ".state\redis-cluster\conf\node2\redis.conf"
    New-RedisConf -Port "7003" -OutputFile ".state\redis-cluster\conf\node3\redis.conf"

    # Create bin directory if it doesn't exist
    if (-not (Test-Path ".state\redis-cluster\bin")) {
        New-Item -Path ".state\redis-cluster\bin" -ItemType Directory -Force | Out-Null
    }

    # Generate Redis cluster creation script with host IP
    Write-Host "Generating cluster creation script..."
    $clusterScriptPath = ".state\redis-cluster\bin\create-cluster.sh"
    New-RedisClusterScript -Port1 "7001" -Port2 "7002" -Port3 "7003" -OutputFile $clusterScriptPath

    Setup-Kernel-Params-Windows
    Setup-Port-Forward-Windows
}
