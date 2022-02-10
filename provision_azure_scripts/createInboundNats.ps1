$resourceGroup = $args[0]
$prefix = $args[1]

$prefixSafe = $prefix.replace("-", "")
$loadBalancerName = (-join($prefix, "-lb"))
$networkInterface_1Name = (-join($prefix, "-vm1-ni"))
$networkInterface_2Name = (-join($prefix, "-vm2-ni"))

$lbnat1_name = (-join($prefix, "-lb-natrules-rdp_1"))
$lbnat2_name = (-join($prefix, "-lb-natrules-rdp_2"))

Write-Output "Creating Load Balancer Backend Pools"
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