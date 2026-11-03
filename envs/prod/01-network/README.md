# prod / 01-network

## What it deploys
Resource group, VNet `10.30.0.0/16`, subnets (app, func, private endpoint, vm, aks, AzureBastionSubnet) with NSGs, and private DNS zones for Key Vault, Blob, SQL and ACR.
Reads outputs from: nothing (first layer). State key: `tfstate-prod/prod/01-network.tfstate`.

> Only **dev** is meant to be deployed now. `prod` has the same code with its own tfvars, ready for later.

## Prerequisites
- Bootstrap done, `Storage Blob Data Contributor` on the state account, earlier layers applied.
- Values marked `# REPLACE` in `prod.tfvars` are filled in.

## How to run
```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
cd envs/prod/01-network
terraform init
terraform plan -var-file="prod.tfvars" -out tfplan
terraform apply tfplan
```

## How to verify
```powershell
terraform output
az network vnet subnet list --resource-group rg-krconnects-network-prod-cin-001 --vnet-name vnet-krconnects-prod-cin-001 --query "[].{name:name, prefix:addressPrefixes[0], nsg:networkSecurityGroup.id}" -o table
```

## Clean up
Destroy in reverse layer order (05 -> 01):
```powershell
terraform destroy -var-file="prod.tfvars"
```
