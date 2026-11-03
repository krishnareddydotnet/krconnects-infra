# test / 03-data

## What it deploys
Resource group, storage account (no shared keys, private endpoint, versioning, soft delete) with an `uploads` container, Azure SQL (Entra ID-only, private endpoint, TDE, auditing) and diagnostic settings.
Reads outputs from: 01-network, 02-security. State key: `tfstate-test/test/03-data.tfstate`.

> Only **dev** is meant to be deployed now. `test` has the same code with its own tfvars, ready for later.

## Prerequisites
- Bootstrap done, `Storage Blob Data Contributor` on the state account, earlier layers applied.
- Values marked `# REPLACE` in `test.tfvars` are filled in.

## How to run
```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
cd envs/test/03-data
terraform init
terraform plan -var-file="test.tfvars" -out tfplan
terraform apply tfplan
```

## How to verify
```powershell
terraform output
az sql server show --name sql-krconnects-test-cin-001 --resource-group rg-krconnects-data-test-cin-001 --query "{public:publicNetworkAccess, entraOnly:administrators.azureAdOnlyAuthentication, tls:minimalTlsVersion}"
```

## Clean up
Destroy in reverse layer order (05 -> 01):
```powershell
terraform destroy -var-file="test.tfvars"
```
