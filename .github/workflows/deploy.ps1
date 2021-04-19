Write-Output "path: $Env:path"
Write-Output "rg name: $Env:resourceGroupName"
Write-Output "ws name: $Env:workspaceName"

Get-ChildItem "$Env:path\Detections" -Filter *.json |
ForEach-Object {
    Write-Output $_.FullName
}