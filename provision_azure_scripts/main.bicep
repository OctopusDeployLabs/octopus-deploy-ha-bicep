param prefix string
param location string
param storageAccount_key string
param license_key string
param admin_username string
param admin_email string
@secure()
param admin_password string

param sqlServer_admin_username string
@secure()
param sqlServer_admin_password string

var virtualMachine_1_name = '${prefix}-vm1'
var virtualMachine_2_name = '${prefix}-vm2'

var virtualMachine_1_InstallOcto_name = '${virtualMachine_1_name}-installocto'
var virtualMachine_2_InstallOcto_name = '${virtualMachine_2_name}-installocto'

var virtualMachine_1_disk_name = '${virtualMachine_1_name}-osdisk'
var virtualMachine_2_disk_name = '${virtualMachine_2_name}-osdisk'

var networkSecurityGroup_1_name = '${virtualMachine_1_name}-nsg'
var networkSecurityGroup_2_name = '${virtualMachine_2_name}-nsg'

//var ipAddress_1_name = '${virtualMachine_1_name}-ip'
//var ipAddress_2_name = '${virtualMachine_2_name}-ip'

var vnet_name = '${prefix}-vnet'

var networkInterface_1_name = '${virtualMachine_1_name}-ni'
var networkInterface_2_name = '${virtualMachine_2_name}-ni'

var networkInterface_1_ipAddress = '172.27.0.4'
var networkInterface_2_ipAddress = '172.27.0.5'

var sqlServer_name = '${prefix}-sql'
var sqlServerDatabase_name = '${prefix}-db'
var sqlServer_ConnectionString =  'Data Source=${sqlServer_name}.database.windows.net;Initial Catalog=${sqlServerDatabase_name};Integrated Security=False;User ID=${sqlServer_admin_username};Password=${sqlServer_admin_password}'

var loadBalancer_name = '${prefix}-lb'
var loadBalancer_ipAddress_name = '${prefix}-lb-ip'

var loadBalancer_backEndAddressPool_name = '${loadBalancer_name}-backend-address-pool'
var loadBalancer_frontEndIPConfig_name = '${loadBalancer_name}-frontend-ipconfig'
var loadBalancer_rules_80_name = '${loadBalancer_name}-rules-80'
var loadBalancer_rules_443_name = '${loadBalancer_name}-rules-443'

var loadBalancer_natrules_rdp_1_name = '${loadBalancer_name}-natrules-rdp_1'
var loadBalancer_natrules_rdp_2_name = '${loadBalancer_name}-natrules-rdp_2'

var loadBalancer_probes_http_name = '${loadBalancer_name}-http-probe'
var loadBalancer_probes_https_name = '${loadBalancer_name}-https-probe'

var natGateway_name = '${prefix}-nat'

var natGateway_ipAddress_name = '${prefix}-nat-ip'

var prefix_safe = replace(prefix, '-', '')
var storageAccount_name = '${prefix_safe}storage'
var storageAccount_FileShare_name = '${prefix}-fileshare'

resource networkSecurityGroup_1 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroup_1_name
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource networkSecurityGroup_2 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroup_2_name
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

/*
resource ipAddress_1 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: ipAddress_1_name
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource ipAddress_2 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: ipAddress_2_name
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}
*/

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.27.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '172.27.0.0/24'
          natGateway: {
            id: natGateway.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualMachine_1 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: virtualMachine_1_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: virtualMachine_1_disk_name
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachine_1_name
      adminUsername: admin_username
      adminPassword: admin_password
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_1.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource virtualMachine_1_InstallOcto 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  parent: virtualMachine_1
  name: virtualMachine_1_InstallOcto_name
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/install_vm1.ps1'
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File install_vm1.ps1 "${storageAccount_name}" "${storageAccount_FileShare_name}" "${storageAccount_key}" "${sqlServer_ConnectionString}" "${admin_username}" "${admin_email}" "${admin_password}" "${license_key}"'
    }
  }
  dependsOn: [
    virtualMachine_1
    virtualMachine_2
    sqlServer
    sqlServerDatabase
  ]
}

resource virtualMachine_2 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: virtualMachine_2_name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: virtualMachine_2_disk_name
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachine_2_name
      adminUsername: admin_username
      adminPassword: admin_password
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_2.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource virtualMachine_2_InstallOcto 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  parent: virtualMachine_2
  name: virtualMachine_2_InstallOcto_name
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/install_vmx.ps1'
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File install_vmx.ps1 "${storageAccount_name}" "${storageAccount_FileShare_name}" "${storageAccount_key}" "${sqlServer_ConnectionString}" "${admin_username}" "${admin_email}" "${admin_password}" "${license_key}"'
    }
  }
  dependsOn: [
    virtualMachine_1
    virtualMachine_1_InstallOcto
    virtualMachine_2
    sqlServer
    sqlServerDatabase
  ]
}

resource rdp_1 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_1
  name: 'RDP'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 300
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource rdp_2 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_2
  name: 'RDP'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 300
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource smb_1 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_1
  name: 'SMB'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '445'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 310
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource smb_2 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_2
  name: 'SMB'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '445'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 310
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpin_1 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_1
  name: 'HTTP_In'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 350
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpin_2 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_2
  name: 'HTTP_In'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 350
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpsin_1 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_1
  name: 'HTTPS_In'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 360
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpsin_2 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_2
  name: 'HTTPS_In'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 360
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpout_1 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_1
  name: 'HTTP_Out'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 370
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpout_2 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_2
  name: 'HTTP_Out'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 370
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpsout_1 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_1
  name: 'HTTPS_Out'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 380
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource httpsout_2 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroup_2
  name: 'HTTPS_Out'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 380
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet
  name: 'default'
  properties: {
    addressPrefix: '172.27.0.0/24'
    natGateway: {
      id: natGateway.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkInterface_1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterface_1_name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: networkInterface_1_ipAddress
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    networkSecurityGroup: {
      id: networkSecurityGroup_1.id
    }
  }
}

resource networkInterface_2 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterface_2_name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: networkInterface_2_ipAddress
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    networkSecurityGroup: {
      id: networkSecurityGroup_2.id
    }
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: loadBalancer_name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: loadBalancer_frontEndIPConfig_name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: loadBalancer_ipAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: loadBalancer_backEndAddressPool_name
        properties: {
          loadBalancerBackendAddresses: [
            {
              name: '${loadBalancer_backEndAddressPool_name}-address-1'
              properties: {
                virtualNetwork: {
                  id: vnet.id
                }
                ipAddress: networkInterface_1_ipAddress
              }
            }
            {
              name: '${loadBalancer_backEndAddressPool_name}-address-2'
              properties: {
                virtualNetwork: {
                  id: vnet.id
                }
                ipAddress: networkInterface_2_ipAddress
              }
            }
          ]
        }
      }
    ]
    loadBalancingRules: [
      {
        name: loadBalancer_rules_80_name
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          loadDistribution: 'SourceIP'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancer_name, loadBalancer_frontEndIPConfig_name)
          } 
          backendAddressPool: {
            id:  resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer_name, loadBalancer_backEndAddressPool_name)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancer_name, loadBalancer_probes_http_name)
          }
        }
      }
      {
        name: loadBalancer_rules_443_name
        properties: {
          protocol: 'Tcp'
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          loadDistribution: 'SourceIP'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancer_name, loadBalancer_frontEndIPConfig_name)
          } 
          backendAddressPool: {
            id:  resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer_name, loadBalancer_backEndAddressPool_name)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancer_name, loadBalancer_probes_https_name)
          }
        }
      }
    ]
    inboundNatRules: [
      {
        name: loadBalancer_natrules_rdp_1_name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancer_name, loadBalancer_frontEndIPConfig_name)
          }
          frontendPort: 3389
          backendPort: 3389
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          protocol: 'Tcp'
          enableTcpReset: false
        }
      }
      {
        name: loadBalancer_natrules_rdp_2_name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancer_name, loadBalancer_frontEndIPConfig_name)
          }
          frontendPort: 3390
          backendPort: 3389
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          protocol: 'Tcp'
          enableTcpReset: false
        }
      }
    ]
    probes: [
      {
        name: loadBalancer_probes_http_name
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
      {
        name: loadBalancer_probes_https_name
        properties: {
          protocol: 'Tcp'
          port: 443
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource loadBalancer_ipAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: loadBalancer_ipAddress_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource natGateway 'Microsoft.Network/natGateways@2020-11-01' = {
  name: natGateway_name
  location: 'northeurope'
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGateway_ipAddress.id
      }
    ]
  }
}

resource natGateway_ipAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: natGateway_ipAddress_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource sqlServer 'Microsoft.Sql/servers@2020-11-01-preview' ={
  name: sqlServer_name
  location: location
  properties: {
    administratorLogin: sqlServer_admin_username
    administratorLoginPassword: sqlServer_admin_password
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  parent: sqlServer
  name: sqlServerDatabase_name
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}
