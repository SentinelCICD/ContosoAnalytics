param (
    [Parameter(Mandatory=$true)][string]$path,
    [Parameter(Mandatory=$true)][string]$resourceGroupName,
    [Parameter(Mandatory=$true)][string]$workspaceName
)
Write-Output "path: $path"
Write-Output "rg name: $resourceGroupName"
Write-Output "ws name: $workspaceName"

Get-ChildItem "$path\Detections" -Filter *.json |
ForEach-Object {
    Write-Output $_.FullName
}