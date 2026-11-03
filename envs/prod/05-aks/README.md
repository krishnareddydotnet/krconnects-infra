# prod / 05-aks

## What it deploys
Resource group, ACR (Premium, private endpoint), AKS (Entra ID + Azure RBAC, Workload Identity, Azure Policy, Container Insights), `AcrPull` for the kubelet, and a Workload Identity for `orders/orders-sa` with `Key Vault Secrets User`.
Reads outputs from: 01-network, 02-security. State key: `tfstate-prod/prod/05-aks.tfstate`.

Cost: ACR Premium and the AKS nodes are billed hourly. Destroy dev when you finish practising.

> Only **dev** is meant to be deployed now. `prod` has the same code with its own tfvars, ready for later.

## Prerequisites
- Bootstrap done, `Storage Blob Data Contributor` on the state account, earlier layers applied.
- Values marked `# REPLACE` in `prod.tfvars` are filled in.

## How to run
```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
cd envs/prod/05-aks
terraform init
terraform plan -var-file="prod.tfvars" -out tfplan
terraform apply tfplan
```

## How to verify
```powershell
terraform output
az aks show --resource-group rg-krconnects-aks-prod-cin-001 --name aks-krconnects-prod-cin-001 --query "{private:apiServerAccessProfile.enablePrivateCluster, wi:securityProfile.workloadIdentity.enabled, localAccounts:disableLocalAccounts}"
```

## Clean up
Destroy in reverse layer order (05 -> 01):
```powershell
terraform destroy -var-file="prod.tfvars"
```
