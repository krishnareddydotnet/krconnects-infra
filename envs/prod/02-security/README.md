# prod / 02-security

## What it deploys
Resource group, Key Vault (RBAC, purge protection, private endpoint), Log Analytics workspace with Key Vault diagnostics, and the AKS control-plane managed identity.
Reads outputs from: 01-network. State key: `tfstate-prod/prod/02-security.tfstate`.

> Only **dev** is meant to be deployed now. `prod` has the same code with its own tfvars, ready for later.

## Prerequisites
- Bootstrap done, `Storage Blob Data Contributor` on the state account, earlier layers applied.
- Values marked `# REPLACE` in `prod.tfvars` are filled in.

## How to run
```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
cd envs/prod/02-security
terraform init
terraform plan -var-file="prod.tfvars" -out tfplan
terraform apply tfplan
```

## How to verify
```powershell
terraform output
az keyvault show --name kv-krc-prod-cin-001 --query "properties.{rbac:enableRbacAuthorization, public:publicNetworkAccess, purge:enablePurgeProtection}"
```

## Clean up
Destroy in reverse layer order (05 -> 01):
```powershell
terraform destroy -var-file="prod.tfvars"
```
