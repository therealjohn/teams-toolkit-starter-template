param name string
param location string = resourceGroup().location
param tags object = {}

@maxLength(42)
param botDisplayName string
param botServiceSku string = 'F0'
param botAadAppClientId string
param botAppDomain string
param kind string = 'azurebot'

resource botService 'Microsoft.BotService/botServices@2022-09-15' = {
  name: name
  location: 'global'
  tags: tags
  kind: kind
  properties: {
    displayName: botDisplayName
    endpoint: '${botAppDomain}/api/messages'
    msaAppId: botAadAppClientId
  }
  sku: {
    name: botServiceSku
  }
}

resource botServiceMsTeamsChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
  parent: botService
  location: 'global'
  name: 'MsTeamsChannel'
  properties: {
    channelName: 'MsTeamsChannel'
  }
}
