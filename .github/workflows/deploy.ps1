Write-Output "rg name: $Env:resourceGroupName"
Write-Output "ws name: $Env:workspaceName"
Write-Output "Starting Deployment for Files in path: $Env:directory"

Get-ChildItem $Env:directory -Filter *.json |
ForEach-Object {
    $FullPathToTemplateFile = $_.FullName
    New-AzManagementGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $FullPathToTemplateFile -logAnalyticsWorkspaceName $Env:workspaceName
}