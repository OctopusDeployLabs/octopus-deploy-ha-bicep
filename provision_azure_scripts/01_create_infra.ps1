$resourceGroup = $args[0]
$prefix = $args[1]
$location = $args[2]
$adminUsername = $args[3]
$adminPassword = $args[4]
$sqlServerAdminUsername = $args[5]
$sqlServerAdminPassword = $args[6]

$prefixSafe = $prefix.replace("-", "")
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

$storageAcctKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageName)[0].Value

Write-Output (-join("Storage Account Key = ", $storageAcctKey))

# Create Main Deployment

Write-Output "Provisioning Main Deployment"
Write-Output (-join("Prefix = ", $prefix))
Write-Output (-join("Location = ", $location))
Write-Output (-join("Admin Username = ", $adminUsername))
Write-Output (-join("SQL Server Admin Username = ", $sqlServerAdminUsername))
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

# Create Load Balancer BackEnd Pools

Write-Output "Creating Load Balancer Backend Pools"

$loadBalancerName = (-join($prefix, "-lb"))
$vnetName = (-join($prefix, "-vnet"))
$networkInterface_1_ipAddress = '172.27.0.4'
$networkInterface_2_ipAddress = '172.27.0.5'

Write-Output (-join("Load Balancer Name = ", $loadBalancerName))
Write-Output (-join("VNet Name = ", $vnetName))
Write-Output (-join("IP 1 Address = ", $networkInterface_1_ipAddress))
Write-Output (-join("IP 2 Address = ", $networkInterface_2_ipAddress))

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $resourceGroup -Name $loadBalancerName
$backendPool = $lb | Get-AzLoadBalancerBackendAddressPool

$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup 
 
$ip1 = New-AzLoadBalancerBackendAddressConfig -IpAddress $networkInterface_1_ipAddress -Name "VNetRef1" -VirtualNetwork $virtualNetwork.id
$ip2 = New-AzLoadBalancerBackendAddressConfig -IpAddress $networkInterface_2_ipAddress -Name "VNetRef2" -VirtualNetwork $virtualNetwork.id
 
$backendPool.LoadBalancerBackendAddresses.Add($ip1) 
$backendPool.LoadBalancerBackendAddresses.Add($ip2)

Set-AzLoadBalancerBackendAddressPool -InputObject $backendPool
