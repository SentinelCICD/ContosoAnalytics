function AttemptSignIn {
    $RawCreds = $Env:creds | ConvertFrom-Json

    Write-Output ${RawCreds.activeDirectoryEndpointUrl};
    Write-Output ${RawCreds.resourceManagerEndpointUrl};
    Write-Output ${RawCreds.clientId};
    Write-Output ${RawCreds.tenantId};
    Write-Output ${RawCreds.subscriptionId};
    Write-Output ${RawCreds.azureCloud};
    Write-Output ${RawCreds.activeDirectoryEndpointUrl};

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
    Write-Output "Attempting Sign In"
    AttemptSignIn
}

Write-Output "Starting Deployment for Files in path: $Env:directory"

Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}