# Cleanup script for Redis Cluster port-forward and firewall setup on Windows
# This script removes port proxy rules and firewall rules created during startup


function Cleanup-Port-Forward-Windows {
    param (
        [string]$RuleName = "Redis Cluster",
        [int[]]$Ports = @(7001, 7002, 7003, 17001, 17002, 17003)
    )

    Write-Host "Cleaning up Redis Cluster port-forward and firewall setup..."

    # --- Check elevation; prompt to elevate if needed ---
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        $response = Read-Host "Cleanup port forward for Redis-Cluster requires administrator privileges.`nDo you want to run Redis port forward cleanup in a separate window as Administrator? (Y)`nPress y to confirm, press Ctrl+C to skip cleanup"
        if ($response -match '^[Yy]') {
            Write-Host "Restarting script with administrator privileges..."

            # Get the current working directory to pass to elevated session
            $currentDir = Get-Location

            # Build command to run elevated and keep window open
            $cmd = @"
& {
    try {
        Set-Location '$currentDir'
        . '.\.infra\redis-cluster\provision\shutdown\cleanup.ps1'
        Cleanup-Port-Forward-Windows
    } catch {
        Write-Host "Error: `$(`$_.Exception.Message)" -ForegroundColor Red
        Write-Host `$_.ScriptStackTrace -ForegroundColor Red
    }
    Write-Host "Cleanup complete. Press any key to close this window..."
    `$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
"@

            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass", "-Command $cmd" -Verb RunAs
        } else {
            Write-Host "Skipping cleanup. Port forwarding rules will remain active."
        }

        return
    }

    # --- Remove Port Proxy Rules ---
    foreach ($port in $Ports) {
        $existingRule = netsh interface portproxy show v4tov4 | Select-String "0.0.0.0\s+$port"
        if ($existingRule) {
            Write-Host "Removing port proxy for port $port"
            netsh interface portproxy delete v4tov4 listenport=$port listenaddress=0.0.0.0 | Out-Null
        } else {
            Write-Host "Port proxy for port $port does not exist -- skipping."
        }

        # --- Remove Firewall Rule ---
        $fwRule = Get-NetFirewallRule -DisplayName "$RuleName-$port" -ErrorAction SilentlyContinue
        if ($fwRule) {
            Write-Host "Removing firewall rule '$RuleName-$port'..."
            Remove-NetFirewallRule -DisplayName "$RuleName-$port" | Out-Null
            Write-Host "Firewall rule '$RuleName-$port' removed."
        } else {
            Write-Host "Firewall rule '$RuleName-$port' does not exist -- skipping."
        }
    }

    Write-Host "Port forwarding and firewall cleanup complete."
}

# Run cleanup if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Cleanup-Port-Forward-Windows
}
