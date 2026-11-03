# One-time Azure + GitHub setup (OIDC, no client secrets)

GitHub Actions signs in to Azure with a short-lived OIDC token. Azure trusts it through a
**federated credential** on a **user-assigned managed identity**. There is no secret to store, leak or rotate.

Replace these placeholders everywhere below:
- `00000000-0000-0000-0000-000000000000` = your subscription ID
- `<...-principal-id>` / `<...-client-id>` = values printed by `az identity show`

## 1. Identities per environment
Two identities per environment (commands below are for **dev**; repeat with `test` / `prod`):

| Identity | Used by | Trusted subject | Can |
|---|---|---|---|
| `id-github-krconnects-dev-cin-001` | apply (merge to main) | `repo:krishnareddydotnet/krconnects-infra:environment:dev` | change resources |
| `id-github-krconnects-dev-plan-cin-001` | plan (pull request) | `repo:krishnareddydotnet/krconnects-infra:pull_request` | read only |

Why two? Anyone who can open a PR can edit the workflow file. The PR identity must not be able to change Azure.
Only the `dev` GitHub Environment (main branch only, approvals for prod) can get the apply identity.

```powershell
az login
az account set --subscription 00000000-0000-0000-0000-000000000000
az group create --name rg-krconnects-identity-cin-001 --location centralindia --tags environment=shared owner=krishna project=krconnects cost-center=cc-1001 managed-by=cli

az identity create --name id-github-krconnects-dev-cin-001 --resource-group rg-krconnects-identity-cin-001 --location centralindia
az identity federated-credential create --name fc-github-env-dev --identity-name id-github-krconnects-dev-cin-001 --resource-group rg-krconnects-identity-cin-001 --issuer https://token.actions.githubusercontent.com --subject repo:krishnareddydotnet/krconnects-infra:environment:dev --audiences api://AzureADTokenExchange

az identity create --name id-github-krconnects-dev-plan-cin-001 --resource-group rg-krconnects-identity-cin-001 --location centralindia
az identity federated-credential create --name fc-github-pull-request --identity-name id-github-krconnects-dev-plan-cin-001 --resource-group rg-krconnects-identity-cin-001 --issuer https://token.actions.githubusercontent.com --subject repo:krishnareddydotnet/krconnects-infra:pull_request --audiences api://AzureADTokenExchange

az identity show --name id-github-krconnects-dev-cin-001 --resource-group rg-krconnects-identity-cin-001 --query "{clientId:clientId, principalId:principalId, tenantId:tenantId}"
az identity show --name id-github-krconnects-dev-plan-cin-001 --resource-group rg-krconnects-identity-cin-001 --query "{clientId:clientId, principalId:principalId}"
```

## 2. RBAC roles
Apply identity: `Contributor` + `Role Based Access Control Administrator` (layers create role assignments),
and write access to **its own** state container only.
```powershell
az role assignment create --assignee-object-id <dev-apply-principal-id> --assignee-principal-type ServicePrincipal --role "Contributor" --scope /subscriptions/00000000-0000-0000-0000-000000000000
az role assignment create --assignee-object-id <dev-apply-principal-id> --assignee-principal-type ServicePrincipal --role "Role Based Access Control Administrator" --scope /subscriptions/00000000-0000-0000-0000-000000000000
az role assignment create --assignee-object-id <dev-apply-principal-id> --assignee-principal-type ServicePrincipal --role "Storage Blob Data Contributor" --scope /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-krconnects-tfstate-cin-001/providers/Microsoft.Storage/storageAccounts/stkrctfstatecin001/blobServices/default/containers/tfstate-dev
```

Plan identity: `Reader` + the custom `Terraform Plan Reader` role + read-only state (`plan -lock=false`).
Edit the subscription ID in `docs/terraform-plan-reader-role.json` first (create the role once, not per env).
```powershell
az role definition create --role-definition docs/terraform-plan-reader-role.json
az role assignment create --assignee-object-id <dev-plan-principal-id> --assignee-principal-type ServicePrincipal --role "Reader" --scope /subscriptions/00000000-0000-0000-0000-000000000000
az role assignment create --assignee-object-id <dev-plan-principal-id> --assignee-principal-type ServicePrincipal --role "Terraform Plan Reader" --scope /subscriptions/00000000-0000-0000-0000-000000000000
az role assignment create --assignee-object-id <dev-plan-principal-id> --assignee-principal-type ServicePrincipal --role "Storage Blob Data Reader" --scope /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-krconnects-tfstate-cin-001/providers/Microsoft.Storage/storageAccounts/stkrctfstatecin001/blobServices/default/containers/tfstate-dev
```
If a plan fails with `AuthorizationFailed`, the error names the missing action: add it to the custom role.

> Practice setup uses one subscription for all environments. In real life use **one subscription per
> environment**, so the dev identity cannot touch prod at all. You can also add a condition to
> `Role Based Access Control Administrator` that limits which roles it may assign.

## 3. GitHub Environments and variables
In GitHub: **Settings → Environments** → create `dev`, `test`, `prod`. For each:
- **Deployment branches and tags**: Selected branches → `main` only (PR branches cannot use the apply identity).
- `prod` only: **Required reviewers** → add yourself (apply waits for approval).

Variables (IDs are not secrets, so use variables):
```powershell
gh variable set AZURE_TENANT_ID --repo krishnareddydotnet/krconnects-infra --body "<tenant-id>"
gh variable set AZURE_SUBSCRIPTION_ID --repo krishnareddydotnet/krconnects-infra --body "00000000-0000-0000-0000-000000000000"
gh variable set AZURE_PLAN_CLIENT_ID_DEV --repo krishnareddydotnet/krconnects-infra --body "<dev-plan-client-id>"
gh variable set AZURE_CLIENT_ID --repo krishnareddydotnet/krconnects-infra --env dev --body "<dev-apply-client-id>"
```
For test/prod later: `AZURE_PLAN_CLIENT_ID_TEST`, `AZURE_PLAN_CLIENT_ID_PROD`, and `AZURE_CLIENT_ID` in the `test` / `prod` environments.

## 4. Verify
```powershell
az identity federated-credential list --identity-name id-github-krconnects-dev-cin-001 --resource-group rg-krconnects-identity-cin-001 --query "[].{name:name, subject:subject}"
az role assignment list --assignee <dev-apply-principal-id> --all --query "[].{role:roleDefinitionName, scope:scope}" -o table
gh variable list --repo krishnareddydotnet/krconnects-infra
gh variable list --repo krishnareddydotnet/krconnects-infra --env dev
```
