# Import global functions (assuming there's a PowerShell equivalent)
. ".\.infra\global\libs\functions.ps1"

# Create dev namespace
$body = @{
    customNamespaceId = "dev"
    namespaceName = "dev"
    namespaceDesc = "development"
}

Invoke-RestMethod                                            `
    -Uri "http://localhost:8848/nacos/v1/console/namespaces" `
    -Method Post                                             `
    -Body $body
