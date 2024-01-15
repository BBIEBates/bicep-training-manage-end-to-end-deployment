githubOrganizationName='bbiebates'
githubRepositoryName='bicep-training-manage-end-to-end-deployment'

testApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-end-to-end-test-bates')
testApplicationRegistrationObjectId=$(echo $testApplicationRegistrationDetails | jq -r '.id')
testApplicationRegistrationAppId=$(echo $testApplicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
   --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-test-bates\",
   \"issuer\":\"https://token.actions.githubusercontent.com\",
   \"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Test\",
   \"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-test-branch-bates\",
   \"issuer\":\"https://token.actions.githubusercontent.com\",
   \"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",
   \"audiences\":[\"api://AzureADTokenExchange\"]}"

productionApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-end-to-end-production-bates')
productionApplicationRegistrationObjectId=$(echo $productionApplicationRegistrationDetails | jq -r '.id')
productionApplicationRegistrationAppId=$(echo $productionApplicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
   --id $productionApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-production-bates\",
   \"issuer\":\"https://token.actions.githubusercontent.com\",
   \"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Production\",
   \"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $productionApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-production-branch-bates\",
   \"issuer\":\"https://token.actions.githubusercontent.com\",
   \"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",
   \"audiences\":[\"api://AzureADTokenExchange\"]}"

testResourceGroupResourceId=$(az group create --name BatesToyWebsiteTest --location westus3 --query id --output tsv)

az ad sp create --id $testApplicationRegistrationObjectId
az role assignment create \
   --assignee $testApplicationRegistrationAppId \
   --role Contributor \
   --scope /$testResourceGroupResourceId

productionResourceGroupResourceId=$(az group create --name BatesToyWebsiteProduction --location westus3 --query id --output tsv)

az ad sp create --id $productionApplicationRegistrationObjectId
az role assignment create \
   --assignee $productionApplicationRegistrationAppId \
   --role Contributor \
   --scope /$productionResourceGroupResourceId

echo "AZURE_CLIENT_ID_TEST: $testApplicationRegistrationAppId"
echo "AZURE_CLIENT_ID_PRODUCTION: $productionApplicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"