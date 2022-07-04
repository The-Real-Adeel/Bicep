// Create App Service Plan and App Services. Production (default) and a second staging
// Create Storage Accounts that the app service apps (prod/stage) will have access to via Managed Identity
// Create Managed Identity that will be assigned within the apps resource
// Create RBAC roles and assign the managed identity access to the storage account

param locationP string = resourceGroup().location
param PythonP string = 'PYTHON|3.8'

var appServiceNameV = 'Corpo-AppService'

//Create App Service Plan
resource appServicePlanR 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${appServiceNameV}-plan-${locationP}'
  location: locationP
  sku: {
    name: 'S1'
  }
  kind: 'linux'
  properties:{
    reserved: true //must include this if you want the OS to switch to linux in order to get Python to work.
  }
}

//create the app service app for production
resource appServiceAppR 'Microsoft.Web/sites@2021-03-01' = {
  name: '${appServiceNameV}-App-${locationP}'
  location: locationP
  properties: {
    serverFarmId: appServicePlanR.id
    siteConfig: {
      linuxFxVersion: PythonP
    }
    httpsOnly:true
  }
  identity: { //assign user assigned identity resource to webapp using MI resource ID
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityR.id}': {}
    }
  }
}

//create the app service app deployment slots called staging
resource appServiceSlotR 'Microsoft.Web/sites/slots@2021-03-01' = {
  parent: appServiceAppR
  name: 'Staging'
  location: locationP
  properties: {
    serverFarmId: appServicePlanR.id
    siteConfig: {
      linuxFxVersion: PythonP
    }
    httpsOnly:true
  }
  identity: { //assign user assigned identity resource to webapp using MI resource ID
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityR.id}': {}
    }
  }
}

//create storageAccounts that the app will have access to via managed identity
//Create blob service resource followed by the container
resource storageAccountR 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'corpostoracc01'
  location: locationP
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
  kind: 'StorageV2'
}
resource  blobServiceR 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccountR
  name: 'default'
}
resource containerBlobServicesR 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: blobServiceR
  name: 'corpo-container01'
}

//Create User Assigned Managed Identity. This will be referenced in the App Services
resource managedIdentityR 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: '${appServiceNameV}-MI'
  location: locationP 
}

//'This is the built-in "Storage Blob Data Contributor" role. that will allow the resource to work with the files inside the container
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

//Create RBAC roles for the storage account container! it will have access to the data inside
resource storageAccountContainerRBACR 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: containerBlobServicesR
  name: guid(storageAccountR.id, managedIdentityR.id, contributorRoleDefinition.id)
  properties: {
    principalId: managedIdentityR.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinition.id
  }
}

output appServiceAppHostName string = appServiceAppR.properties.defaultHostName
output appServiceStageHostName string = appServiceSlotR.properties.defaultHostName
