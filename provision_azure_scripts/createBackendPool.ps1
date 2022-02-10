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