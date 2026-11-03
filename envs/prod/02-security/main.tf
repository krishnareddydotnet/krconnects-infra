# Two module source styles, side by side:
# - Local module : source = "../../../modules/tags"  (lives in this repo, changes with it)
# - Remote module: source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/<name>?ref=v1.0.0"
#                  (shared repo, pinned to a git tag, upgraded on purpose with a PR)
module "naming" {
  source = "../../../modules/tags"

  project       = "krconnects"
  project_short = "krc"
  environment   = var.environment
  workload      = "security"
  owner         = var.owner
  cost_center   = var.cost_center
}

# Reads the outputs of layer 01-network from its state file (read-only).
data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate-${var.environment}"
    key                  = "${var.environment}/01-network.tfstate"
    use_azuread_auth     = true
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "security" {
  name     = module.naming.resource_group_name
  location = var.location
  tags     = module.naming.tags
}

module "key_vault" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/key-vault?ref=v1.0.0"

  name                       = "kv-${module.naming.short_suffix}"
  resource_group_name        = azurerm_resource_group.security.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = var.key_vault_soft_delete_days
  private_endpoint_subnet_id = data.terraform_remote_state.network.outputs.subnet_id_pe
  private_dns_zone_id        = data.terraform_remote_state.network.outputs.dns_zone_id_key_vault
  tags                       = module.naming.tags
}

module "log_analytics" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/log-analytics?ref=v1.0.0"

  name                = "log-${module.naming.suffix}"
  resource_group_name = azurerm_resource_group.security.name
  location            = var.location
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.log_daily_quota_gb

  diagnostic_settings = {
    "kv" = module.key_vault.id
  }

  tags = module.naming.tags
}

# Control-plane identity for AKS (layer 05). Created here so security owns identities.
module "aks_identity" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/managed-identity?ref=v1.0.0"

  name                = "id-aks-${module.naming.suffix}"
  resource_group_name = azurerm_resource_group.security.name
  location            = var.location
  tags                = module.naming.tags
}
