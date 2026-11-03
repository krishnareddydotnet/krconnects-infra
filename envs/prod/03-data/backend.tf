# Remote state: one key per environment + layer, in the environment's own container.
# Backend blocks cannot use variables, so the values are literal.
# use_azuread_auth = true: Entra ID (your az login or the pipeline OIDC identity), no storage keys.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-krconnects-tfstate-cin-001"
    storage_account_name = "stkrctfstatecin001"
    container_name       = "tfstate-prod"
    key                  = "prod/03-data.tfstate"
    use_azuread_auth     = true
  }
}
