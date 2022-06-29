// P = Parameter Name suffix
// V = Variable Symbolic suffix
// R = Resource Symbolic Name suffix

// create storage account
// create an array of containers

// The storage Accounts has other resources (Blob service & Containers) that are now nested within the storage account resource
// These resources will pull the API version from the storage account resource as well as the path
// i.e containerBlobServicesR is using Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01

param locationN string = resourceGroup().location
param corpN string = 'corpo'
// param rgN string = resourceGroup().name

resource storageAccountR 'Microsoft.Storage/storageAccounts@2021-09-01'= {
  name: '${corpN}sa${locationN}'
  location: locationN
  sku: { 
    name: 'Standard_LRS' 
  }
  kind: 'StorageV2'
  properties:{
    accessTier:'Hot'
  }
  resource blobServicesR 'blobServices' = {
    name: 'default'
    resource containerBlobServicesR 'containers' = [for int in range(0,10): {
      name: '${corpN}-container0${int}'
    }]
  }
}



