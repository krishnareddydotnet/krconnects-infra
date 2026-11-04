# bootstrap

## What it deploys
The remote-state storage once for all environments: `rg-krconnects-tfstate-cin-001`,
storage account `stkrctfstatecin001` (ZRS, versioning, 30-day soft delete, TLS 1.2, no shared keys, RBAC only),
containers `tfstate-dev`, `tfstate-test`, `tfstate-prod`, `Storage Blob Data Contributor` for you, and a delete lock.

It uses **local state** (chicken-and-egg: the backend does not exist yet). `terraform.tfstate` stays on your
machine and is git-ignored. Keep it safe; you only need it to change or destroy the bootstrap.

## Prerequisites
- Azure CLI, Terraform 1.17+.
- `Owner` on the subscription (creates a role assignment and a lock).
- If `stkrctfstatecin001` is taken, choose another name and update it in every `backend.tf`.

## How to run
```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
cd bootstrap
terraform init
terraform plan -var "subscription_id=00000000-0000-0000-0000-000000000000" -out tfplan
terraform apply tfplan
```

## How to verify
```powershell
az storage account show --name stkrctfstatecin001 --resource-group rg-krconnects-tfstate-cin-001 --query "{sharedKey:allowSharedKeyAccess, tls:minimumTlsVersion, publicBlob:allowBlobPublicAccess}"
az storage container list --account-name stkrctfstatecin001 --auth-mode login --query "[].name"
```

## Clean up
Only when every environment is destroyed. Terraform removes the delete lock first, then the account:
```powershell
terraform destroy -var "subscription_id=00000000-0000-0000-0000-000000000000"
```
