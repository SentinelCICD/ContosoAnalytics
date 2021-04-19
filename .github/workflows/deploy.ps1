Write-Output "path: $Env:path"
Write-Output "rg name: $Env:resourceGroupName"
Write-Output "ws name: $Env:workspaceName"
$loc = Get-Location
Write-Output $loc

$BasePath = "${Env:path}\Detections:"

Write-Output "Starting Deployment for Files in path: $BasePath"

Get-ChildItem $BasePath -Filter *.json |
ForEach-Object {
    $FullPathToTemplateFile = $_.FullName
    New-AzManagementGroupDeployment -ResourceGroupName $Env:resourceGroupName -TemplateFile $FullPathToTemplateFile -logAnalyticsWorkspaceName $Env:workspaceName
}