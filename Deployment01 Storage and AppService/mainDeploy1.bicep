// This bicep file will run and create the following resources: storage account, App Service Plan and App Services.
// The SKUs of services will depend on whether the environment you are creating for is Production and NonProd
// Bicep file connects to two modules where both storage account and app services sit. This file will reference both

param locationResource string = 'westus3'
param storageAccName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appSvcAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param envType string


// The following will pull data from a module for the storageAccount
module storAcc 'Modules/storageAcct.bicep' = {
  name: 'storageAcct'
  params: {
    locationResource: locationResource
    storageAccName:storageAccName
    envType: envType
  }
}

// The following will pull data from a module for appservice
module appServ 'Modules/appService.bicep' = {
  name: 'appService'
  params: {
    locationResource: locationResource
    appSvcAppName: appSvcAppName
    envType: envType
  }
}

output appServiceAppHostName string = appServ.outputs.appServiceAppHostName
output StorageAccOutput string = storageAccName
