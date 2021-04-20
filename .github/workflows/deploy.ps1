Write-Output "rg name: $Env:resourceGroupName"
Write-Output "ws name: $Env:workspaceName"

Write-Output "Starting Deployment for Files in path: $Env:directory"

AttemptSignIn

Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}

function AttemptSignIn {
    Write-Output "Attempting Sign In"
    $RawCreds = $Env:creds | ConvertFrom-Json

    Clear-AzContext -Scope Process;
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue;
    
    Add-AzEnvironment `
        -Name $Env:azureCloud `
        -ARMEndpoint $RawCreds.resourceManagerEndpointUrl `
        -ActiveDirectoryEndpoint $RawCreds.activeDirectoryEndpointUrl `
        -GraphResourceId $RawCreds.activeDirectoryGraphResourceId `
        | out-null;

    $servicePrincipalKey = ConvertTo-SecureString $RawCreds.clientSecret.replace("'", "''") -AsPlainText -Force
    $psCredential = New-Object System.Management.Automation.PSCredential($RawCreds.clientId, $servicePrincipalKey)

    Connect-AzAccount -ServicePrincipal -Tenant $Env:tenantId -Credential $psCredential

}
