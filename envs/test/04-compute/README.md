# test / 04-compute

## What it deploys
Resource group, Linux VM (no public IP, SSH key only, Bastion off), App Service plan + .NET web app, Function App plan + .NET function app, `Key Vault Secrets User` for each identity, and diagnostic settings.
Reads outputs from: 01-network, 02-security, 03-data. State key: `tfstate-test/test/04-compute.tfstate`.

Cost: two App Service plans and a VM are billed hourly. `bastion_enabled = false` (Bastion is premium-priced).

> Only **dev** is meant to be deployed now. `test` has the same code with its own tfvars, ready for later.

## Prerequisites
- Bootstrap done, `Storage Blob Data Contributor` on the state account, earlier layers applied.
- Values marked `# REPLACE` in `test.tfvars` are filled in.

## How to run
```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
cd envs/test/04-compute
terraform init
terraform plan -var-file="test.tfvars" -out tfplan
terraform apply tfplan
```

## How to verify
```powershell
terraform output
az webapp show --resource-group rg-krconnects-compute-test-cin-001 --name app-krconnects-test-cin-001 --query "{httpsOnly:httpsOnly, tls:siteConfig.minTlsVersion, vnet:virtualNetworkSubnetId}"
```

## Clean up
Destroy in reverse layer order (05 -> 01):
```powershell
terraform destroy -var-file="test.tfvars"
```
