#!/bin/bash

RESOURCE_GROUP_NAME=tstate2
STORAGE_ACCOUNT_NAME=tstate$RANDOM
CONTAINER_NAME=tstate
KEYVAULT_NAME=kvault$RANDOM

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus2

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
az keyvault create --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP_NAME" --location eastus2
az keyvault secret set --vault-name "$KEYVAULT_NAME" --name "terraform-backend-key" --value $ACCOUNT_KEY
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name $KEYVAULT_NAME --query value -o tsv)
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
sudo apt-get update && sudo apt-get install terraform
