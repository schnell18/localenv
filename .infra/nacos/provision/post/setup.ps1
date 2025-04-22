# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

# Create dev namespace
$body = @{
    customNamespaceId = "dev"
    namespaceName = "dev"
    namespaceDesc = "development"
}

$retries = 15
while($true) {
    try {
        $retries = $retries - 1
        Invoke-RestMethod                                            `
            -Uri "http://localhost:8848/nacos/v1/console/namespaces" `
            -Method Post                                             `
            -Body $body
        break
    }
    catch {
        if ($retries -eq 0) {
            break
        }
    }
    Start-Sleep -Seconds 2
}
