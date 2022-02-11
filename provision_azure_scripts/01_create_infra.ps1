$resourceGroup = $args[0]
$prefix = $args[1]
$location = $args[2]
$adminUsername = $args[3]
$adminEmail = $args[4]
$adminPassword = $args[5]
$sqlServerAdminUsername = $args[6]
$sqlServerAdminPassword = $args[7]
$licenseKey = $args[8]

$licenseKeySafe = $licenseKey.replace('"', '|')

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
Write-Output (-join("Admin Email = ", $adminEmail))
Write-Output (-join("SQL Server Admin Username = ", $sqlServerAdminUsername))
Write-Output (-join("Storage Account Key = ", $storageAcctKey))
Write-Output (-join("License Key = ", $licenseKey))
Write-Output (-join("License Key Safe = ", $licenseKeySafe))

az deployment group create --resource-group $resourceGroup `
--template-file main.bicep `
--parameters prefix=$prefix `
--parameters location=$location `
--parameters admin_username=$adminUsername `
--parameters admin_email=$adminEmail `
--parameters admin_password=$adminPassword `
--parameters sqlServer_admin_username=$sqlServerAdminUsername `
--parameters sqlServer_admin_password=$sqlServerAdminPassword `
--parameters storageAccount_key=$storageAcctKey `
--parameters license_key=$licenseKeySafe

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
$backendPool = $loadBalancer | Get-AzLoadBalancerBackendAddressPool

$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup 
 
$ip1 = New-AzLoadBalancerBackendAddressConfig -IpAddress $networkInterface_1_ipAddress -Name "VNetRef1" -VirtualNetwork $virtualNetwork.id
$ip2 = New-AzLoadBalancerBackendAddressConfig -IpAddress $networkInterface_2_ipAddress -Name "VNetRef2" -VirtualNetwork $virtualNetwork.id
 
$backendPool.LoadBalancerBackendAddresses.Add($ip1) 
$backendPool.LoadBalancerBackendAddresses.Add($ip2)

Set-AzLoadBalancerBackendAddressPool -InputObject $backendPool

# Attach Inbound NAT Rules

Write-Output "Attaching Inbound NAT Rules"

$loadBalancerName = (-join($prefix, "-lb"))
$networkInterface_1Name = (-join($prefix, "-vm1-ni"))
$networkInterface_2Name = (-join($prefix, "-vm2-ni"))

$lbnat1_name = (-join($prefix, "-lb-natrules-rdp_1"))
$lbnat2_name = (-join($prefix, "-lb-natrules-rdp_2"))

Write-Output (-join("Load Balancer Name = ", $loadBalancerName))
Write-Output (-join("Network Interface 1 Name = ", $networkInterface_1Name))
Write-Output (-join("Network Interface 2 Name = ", $networkInterface_2Name))

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $resourceGroup -Name $loadBalancerName

$lbnat1 = Get-AzLoadBalancerInboundNatRuleConfig -Name $lbnat1_name -LoadBalancer $loadBalancer
$lbnat2 = Get-AzLoadBalancerInboundNatRuleConfig -Name $lbnat2_name -LoadBalancer $loadBalancer

$nic1 = Get-AzNetworkInterface -ResourceGroupName $resourceGroup -Name $networkInterface_1Name
$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.Add($lbnat1)
$nic1 | Set-AzNetworkInterface

$nic2 = Get-AzNetworkInterface -ResourceGroupName $resourceGroup -Name $networkInterface_2Name
$nic2.IpConfigurations[0].LoadBalancerInboundNatRules.Add($lbnat2)
$nic2 | Set-AzNetworkInterface
