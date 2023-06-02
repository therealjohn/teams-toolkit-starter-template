param sku string
param name string
param kind string
param location string = resourceGroup().location

// Azure Storage that hosts your static web site
resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  kind: kind
  location: location
  name: name
  properties: {
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: sku
  }
}

var siteDomain = replace(replace(storage.properties.primaryEndpoints.web, 'https://', ''), '/', '')

output domain string = siteDomain
output id string = storage.id
