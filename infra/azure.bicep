@maxLength(20)
@minLength(4)
@description('Used to generate names for all resources in this file')
param resourceBaseName string

@description('Required when create Azure Bot service')
param botAadAppClientId string

@secure()
@description('Required by Bot Framework package in your bot project')
param botAadAppClientSecret string

param webAppSKU string

@maxLength(42)
param botDisplayName string

param serverfarmsName string = resourceBaseName
param webAppName string = resourceBaseName
param location string = resourceGroup().location
param storageName string = resourceBaseName
param storageSku string

module appserviceplan './host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    name: serverfarmsName
    location: location
    sku: {
      name: webAppSKU
    }
  }
}

module appservice './host/appservice.bicep' = {
  name: 'appservice'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appserviceplan.outputs.id
    runtimeName: 'node'
    runtimeVersion: '18-lts'
    alwaysOn: true
    ftpsState: 'FtpsOnly'
    scmDoBuildDuringDeployment: true
  }
}

module webAppSettings './host/appservice-appsettings.bicep' = {
  name: 'appservice-appsettings'
  params: {
    name: appservice.outputs.name    
    appSettings: {
      BOT_ID: botAadAppClientId
      BOT_PASSWORD: botAadAppClientSecret
      RUNNING_ON_AZURE: '1'
    }
  }
}

// The bot service
module bot './bot/botservice.bicep' = {
  name: 'bot'
  params: {
    name: resourceBaseName
    kind: 'azurebot'
    location: location
    botAadAppClientId: botAadAppClientId
    botAppDomain: appservice.outputs.uri
    botDisplayName: botDisplayName
  }
}

// Storage for hosting a web site used in a tab
module storage './host/storage.bicep' = {
  name: 'tab'
  params: {
    name: storageName
    location: location
    kind: 'StorageV2'
    sku: storageSku  
  }
}

// The output will be persisted in .env.{envName}. Visit https://aka.ms/teamsfx-actions/arm-deploy for more details.
output BOT_AZURE_APP_SERVICE_RESOURCE_ID string = appservice.outputs.id
output BOT_DOMAIN string = appservice.outputs.domain
output TAB_AZURE_STORAGE_RESOURCE_ID string = storage.outputs.id // used in deploy stage
output TAB_DOMAIN string = storage.outputs.domain
output TAB_ENDPOINT string = 'https://${storage.outputs.domain}'
