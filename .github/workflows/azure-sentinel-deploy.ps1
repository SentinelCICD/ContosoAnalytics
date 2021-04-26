function ConnectAzCloud {
    $RawCreds = $Env:creds | ConvertFrom-Json
    
    Clear-AzContext -Scope Process;
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue;
    
    Write-Output "ActiveDirectoryServiceEndpointResourceId: ${RawCreds.activeDirectoryServiceEndpointResourceId}";
    Write-Output "ActiveDirectoryEndpoint: ${RawCreds.activeDirectoryEndpointUrl}";
    Write-Output "ResourceManagerEndpoint: ${RawCreds.resourceManagerEndpointUrl}";
    Write-Output "GraphEndpoint: ${RawCreds.graphEndpoint}";
    Write-Output "clientId: ${RawCreds.clientId}";
    Write-Output "tenantId: ${RawCreds.tenantId}";
    Write-Output "subscriptionId: ${RawCreds.subscriptionId}";
    Write-Output "Env:useDefaultCloud: ${Env:useDefaultCloud}";

    Add-AzEnvironment `
        -Name "CustomEnvironment" `
        -ActiveDirectoryServiceEndpointResourceId $RawCreds.activeDirectoryServiceEndpointResourceId `
        -ActiveDirectoryEndpoint $RawCreds.activeDirectoryEndpointUrl `
        -ResourceManagerEndpoint $RawCreds.resourceManagerEndpointUrl `
        -GraphEndpoint $RawCreds.graphEndpoint | out-null;

    $servicePrincipalKey = ConvertTo-SecureString $RawCreds.clientSecret.replace("'", "''") -AsPlainText -Force
    $psCredential = New-Object System.Management.Automation.PSCredential($RawCreds.clientId, $servicePrincipalKey)

    Connect-AzAccount -ServicePrincipal -Tenant $RawCreds.tenantId -Credential $psCredential -Environment "CustomEnvironment" | out-null;
    Set-AzContext -SubscriptionId $RawCreds.subscriptionId -TenantId $RawCreds.tenantId | out-null;
}

if ($Env:useDefaultCloud -eq 'false') {
    Write-Output "Attempting Sign In to Azure Cloud"
    ConnectAzCloud
}

Write-Output "Starting Deployment for Files in path: $Env:directory"
Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}
