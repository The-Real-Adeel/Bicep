*App Service connected to Storage Accounts using user defined MI*

- This bicep file will create app services plan with two deployment slots (production and staging)
- It will create a managed identity that will be user defined and contain both of these deployment slots.
- We will create a storage account > blob services > container which will have RBAC role "Data Contributor" assigned to the MI
