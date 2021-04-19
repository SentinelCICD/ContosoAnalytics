Write-Output "rg name: $Env:resourceGroupName"
Write-Output "ws name: $Env:workspaceName"
Write-Output "Starting Deployment for Files in path: $Env:directory"

Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    New-AzResourceGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $_.FullName -logAnalyticsWorkspaceName $Env:workspaceName
}