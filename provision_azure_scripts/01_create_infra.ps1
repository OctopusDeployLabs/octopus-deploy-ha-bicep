$resourceGroup = $args[0]
$prefix = $args[1]
$location = $args[2]
$adminUsername = $args[3]
$adminPassword = $args[4]
$sqlServerAdminUsername = $args[5]
$sqlServerAdminPassword = $args[6]

$prefixSafe = $prefix.replace(" - ", "")
$storageName = (-join($prefixSafe, "storage"))
$shareName = (-join($prefix, "-fileshare"))
# Create Storage

Write-Output "Creating Storage"
Write-Output (-join("Resource Group = ", $resourceGroup))

az deployment group create --resource-group $resourceGroup `
--template-file storage.bicep `
--parameters prefix=$prefix `
--parameters location=$location


# Create Directories

Write-Output "Creating Directories"
Write-Output (-join("Share Name = ", $shareName))

$storageAcct = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageName

New-AzStorageDirectory `
-Context $storageAcct.Context `
-ShareName $shareName `
-Path "octoha"

New-AzStorageDirectory `
-Context $storageAcct.Context `
-ShareName $shareName `
-Path "octoha\Artifacts"

New-AzStorageDirectory `
-Context $storageAcct.Context `
-ShareName $shareName `
-Path "octoha\Packages"

New-AzStorageDirectory `
-Context $storageAcct.Context `
-ShareName $shareName `
-Path "octoha\TaskLogs"

$storageAcctKey = (Get-AzStorageAccountKey -ResourceGroupName $rgName -Name $saName)[0].Value

Write-Output (-join("Storage Account Key = ", $storageAcctKey))

# Create Main Deployment

Write-Output "Provisioning Main Deployment"
Write-Output (-join("Prefix = ", $prefix))
Write-Output (-join("Location = ", $prefix))
Write-Output (-join("Admin Username = ", $prefix))
Write-Output (-join("SQL Server Admin Username = ", $prefix))
Write-Output (-join("Storage Account Key = ", $storageAcctKey))

az deployment group create --resource-group $resourceGroup `
--template-file main.bicep `
--parameters prefix=$prefix `
--parameters location=$location `
--parameters admin_username=$adminUsername `
--parameters admin_password=$adminPassword `
--parameters sqlServer_admin_username=$sqlServerAdminUsername `
--parameters sqlServer_admin_password=$sqlServerAdminPassword `
--parameters storageAccount_key=$storageAcctKey