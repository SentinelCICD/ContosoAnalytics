
#!/bin/bash
echo "Path to repo root: $1"
echo "Resource Group Name: $2";
echo "Workspace Name: $3";
# cd to repo root folder 
cd $1
echo $PWD
for filename in $PWD/Detections/*.json; do
    az deployment group create --resource-group $1 --template-file $filename --parameters logAnalyticsWorkspaceName='$2'
done