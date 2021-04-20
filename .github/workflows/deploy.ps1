Write-Output "rg name: $Env:resourceGroupName"
Write-Output "ws name: $Env:workspaceName"
Write-Output "creds: $Env:creds"

# Write-Output "Attempting Sign In"
# Connect-AzAccount -ServicePrincipal -Tenant "$Env:tenantId" -Credential \
# (New-Object System.Management.Automation.PSCredential('${servicePrincipalId}'))

Write-Output "Starting Deployment for Files in path: $Env:directory"

Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}