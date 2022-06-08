// Paramaters & Variables
param locationResource string
param appSvcAppName string
@allowed([
  'nonprod'
  'prod'
])
param envType string

var appSvcPlanName = 'toy-product-launch-plan'
var appSvcPlanSkuName = (envType == 'prod') ? 'P2v3' : 'F1'

// Deploy Resources
resource appServPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appSvcPlanName
  location: locationResource
  sku: {
    name: appSvcPlanSkuName
  }  
}

resource appServApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appSvcAppName
  location: locationResource
  properties: {
    serverFarmId: appServPlan.id
    httpsOnly: true
  }
}

output appServiceAppHostName string = appServApp.properties.defaultHostName
