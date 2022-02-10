param prefix string = 'pjg-octo'
param location string = 'northeurope'

var prefix_safe = replace(prefix, '-', '')

var storageAccount_name = '${prefix_safe}storage'
var storageAccount_FileShare_name = '${prefix}-fileshare'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccount_name
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
  properties: {
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }

  resource storageAccount_FileService 'fileServices' = {
    name: 'default'
    properties: {
      protocolSettings: {
        smb: {
          multichannel: {
            enabled: false
          }
        }
      }
      cors: {
        corsRules: []
      }
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
    }
    
    resource storageAccount_FileShare 'shares' = {
      name: storageAccount_FileShare_name
      properties: {
        accessTier: 'Premium'
        shareQuota: 1024
        enabledProtocols: 'SMB'
      }
    }
  }
}
