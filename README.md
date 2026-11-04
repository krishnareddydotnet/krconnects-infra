# krconnects-infra

KRConnects Azure infrastructure (Central India), built from the versioned modules in
[terraform-modules](https://github.com/krishnareddydotnet/terraform-modules). One folder = one layer = one state file.

## Structure
```
bootstrap/                 remote-state storage (run once, local state)
modules/tags/              LOCAL module: standard tags + CAF names (no Azure resources)
envs/
  dev/                     <- only dev is deployed now (cost)
    01-network/            VNet, subnets, NSGs, private DNS zones
    02-security/           Key Vault, Log Analytics, AKS identity
    03-data/               Storage account, Azure SQL
    04-compute/            VM, App Service, Function App
    05-aks/                ACR, AKS, Workload Identity
  test/                    same layers, own tfvars
  prod/                    same layers, own tfvars (bigger SKUs, private AKS, approval)
docs/oidc-setup.md         one-time Azure + GitHub OIDC setup
.github/workflows/         terraform-plan.yml (PR), terraform-apply.yml (main)
```
Each layer has `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `backend.tf`, `<env>.tfvars`, `README.md`.

## Layer order
`01-network → 02-security → 03-data → 04-compute → 05-aks` (destroy in reverse).
Later layers read earlier outputs with `terraform_remote_state` (read-only).
State: container `tfstate-<env>`, key `<env>/<layer>.tfstate`, Entra ID auth (`use_azuread_auth = true`).

## Setup order (one time)
1. [bootstrap](bootstrap) → state storage.
2. [docs/oidc-setup.md](docs/oidc-setup.md) → identities, roles, GitHub Environments and variables.
3. Fill the `# REPLACE` values in `envs/dev/*/dev.tfvars`.
4. First PR → plan → merge → apply, one layer at a time (01 first, since 02 reads 01's state).

## Release flow
```
branch → PR → terraform-plan (fmt, validate, tflint, checkov, plan per changed layer as PR comment)
       → review → squash merge → terraform-apply (dev → test → prod, prod waits for approval)
```
Only changed layers are planned/applied. A change to `modules/tags` runs all layers.

## Bump a module version
1. In terraform-modules, merge the change and push a tag, for example `v1.1.0`.
2. Here, change `?ref=v1.0.0` to `?ref=v1.1.0` in the layers you want (start with dev).
3. Open a PR and read the plan carefully (watch for "must be replaced"). Merge, then promote to test/prod in later PRs.

## Cost notes
- Off by default: Azure Bastion (`bastion_enabled = false`).
- Billed hourly in dev: AKS nodes, ACR Premium (needed for private endpoint), 2 App Service plans (B1), VM, SQL Basic.
- Practising? Apply, verify, then destroy 05 → 01. Keep only bootstrap (a few cents per month).
- test/prod are not deployed. prod tfvars use larger SKUs (P0v3, S0, AKS Standard tier, 3 zones).
- Encryption at host (VM, AKS) needs a one-time registration:
  `az feature register --namespace Microsoft.Compute --name EncryptionAtHost`
