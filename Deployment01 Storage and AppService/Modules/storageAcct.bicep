param locationResource string
param storageAccName string 
@allowed([
  'nonprod'
  'prod'
])
param envType string

var storageAccSkuName = (envType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccName
  location: locationResource
  sku: {
    name: storageAccSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

output StorageAccOutput string = storageAccName
