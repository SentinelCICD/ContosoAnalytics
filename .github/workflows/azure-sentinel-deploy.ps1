function ConnectAzCloud {
    $RawCreds = $Env:creds | ConvertFrom-Json

    Clear-AzContext -Scope Process;
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue;
    
    Add-AzEnvironment `
        -Name $Env:cloudEnv `
        -ActiveDirectoryEndpoint $RawCreds.activeDirectoryEndpointUrl `
        -ResourceManagerEndpoint $RawCreds.resourceManagerEndpointUrl `
        -ActiveDirectoryServiceEndpointResourceId $RawCreds.activeDirectoryServiceEndpointResourceId `
        -GraphEndpoint $RawCreds.graphEndpointUrl | out-null;

    $servicePrincipalKey = ConvertTo-SecureString $RawCreds.clientSecret.replace("'", "''") -AsPlainText -Force
    $psCredential = New-Object System.Management.Automation.PSCredential($RawCreds.clientId, $servicePrincipalKey)

    Connect-AzAccount -ServicePrincipal -Tenant $RawCreds.tenantId -Credential $psCredential -Environment $Env:cloudEnv | out-null;
    Set-AzContext -Tenant $RawCreds.tenantId | out-null;
}

if ($Env:cloudEnv -ne 'AzureCloud') {
    Write-Output "Attempting Sign In to Azure Cloud"
    ConnectAzCloud
}

Write-Output "Starting Deployment for Files in path: $Env:directory"
Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}