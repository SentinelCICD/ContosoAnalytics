function AttemptSignIn {
    Write-Output "Attempting Sign In"
    $RawCreds = $Env:creds | ConvertFrom-Json

    Write-Output "activeDirectoryEndpointUrl: ${RawCreds.activeDirectoryEndpointUrl}";
    Write-Output "resourceManagerEndpointUrl: ${RawCreds.resourceManagerEndpointUrl}";
    Write-Output "clientId: ${RawCreds.clientId}";
    Write-Output "tenantId: ${RawCreds.tenantId}";
    Write-Output "subscriptionId: ${RawCreds.subscriptionId}";
    Write-Output "Env:azureCloud: ${RawCreds.azureCloud}";
    Write-Output "Env:directory: ${RawCreds.activeDirectoryEndpointUrl}";

    Clear-AzContext -Scope Process;
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue;
    
    Add-AzEnvironment `
        -Name "Dogfood" `
        -ActiveDirectoryServiceEndpointResourceId "https://management.core.windows.net/" `
        -ActiveDirectoryEndpoint $RawCreds.activeDirectoryEndpointUrl `
        -ResourceManagerEndpoint $RawCreds.resourceManagerEndpointUrl `
        -GraphEndpoint $RawCreds.activeDirectoryGraphResourceId; # | out-null;

    $servicePrincipalKey = ConvertTo-SecureString $RawCreds.clientSecret.replace("'", "''") -AsPlainText -Force
    $psCredential = New-Object System.Management.Automation.PSCredential($RawCreds.clientId, $servicePrincipalKey)

    Connect-AzAccount -ServicePrincipal -Tenant $RawCreds.tenantId -Credential $psCredential -Environment $Env:azureCloud; # | out-null;
    Set-AzContext -SubscriptionId $RawCreds.subscriptionId -TenantId $RawCreds.tenantId; # | out-null;
}

if (-NOT $Env:azureCloud -eq "Prod") {
    AttemptSignIn
}

Write-Output "Starting Deployment for Files in path: $Env:directory"

Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}