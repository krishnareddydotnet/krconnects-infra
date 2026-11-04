# Two module source styles, side by side:
# - Local module : source = "../../../modules/tags"  (lives in this repo, changes with it)
# - Remote module: source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/<name>?ref=v1.0.0"
#                  (shared repo, pinned to a git tag, upgraded on purpose with a PR)
module "naming" {
  source = "../../../modules/tags"

  project       = "krconnects"
  project_short = "krc"
  environment   = var.environment
  workload      = "aks"
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

# Reads the outputs of layer 02-security from its state file (read-only).
data "terraform_remote_state" "security" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate-${var.environment}"
    key                  = "${var.environment}/02-security.tfstate"
    use_azuread_auth     = true
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "aks" {
  name     = module.naming.resource_group_name
  location = var.location
  tags     = module.naming.tags
}

module "acr" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/acr?ref=v1.0.0"

  name                       = "cr${replace(module.naming.suffix, "-", "")}"
  resource_group_name        = azurerm_resource_group.aks.name
  location                   = var.location
  sku                        = var.acr_sku
  private_endpoint_subnet_id = data.terraform_remote_state.network.outputs.subnet_id_pe
  private_dns_zone_id        = data.terraform_remote_state.network.outputs.dns_zone_id_acr
  tags                       = module.naming.tags
}

module "aks" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/aks?ref=v1.0.0"

  name                            = "aks-${module.naming.suffix}"
  resource_group_name             = azurerm_resource_group.aks.name
  location                        = var.location
  dns_prefix                      = "krconnects-${var.environment}"
  sku_tier                        = var.aks_sku_tier
  private_cluster_enabled         = var.aks_private_cluster_enabled
  api_server_authorized_ip_ranges = var.aks_api_server_authorized_ip_ranges
  identity_id                     = data.terraform_remote_state.security.outputs.aks_identity_id
  identity_principal_id           = data.terraform_remote_state.security.outputs.aks_identity_principal_id
  node_subnet_id                  = data.terraform_remote_state.network.outputs.subnet_id_aks
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids          = var.aks_admin_group_object_ids
  log_analytics_workspace_id      = data.terraform_remote_state.security.outputs.log_analytics_workspace_id
  system_node_count               = var.aks_system_node_count
  user_node_count                 = var.aks_user_node_count
  zones                           = var.aks_zones
  tags                            = module.naming.tags
}

# Nodes pull images with the kubelet identity, no imagePullSecrets.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}

# Workload Identity for the orders service: pods using service account orders/orders-sa
# get Entra ID tokens as this identity and can read Key Vault secrets. No secret in the cluster.
module "orders_identity" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/managed-identity?ref=v1.0.0"

  name                = "id-orders-${module.naming.suffix}"
  resource_group_name = azurerm_resource_group.aks.name
  location            = var.location

  federated_credentials = {
    "fc-aks-orders-sa" = {
      issuer  = module.aks.oidc_issuer_url
      subject = "system:serviceaccount:orders:orders-sa"
    }
  }

  tags = module.naming.tags
}

resource "azurerm_role_assignment" "orders_kv_secrets_user" {
  scope                = data.terraform_remote_state.security.outputs.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.orders_identity.principal_id
}

# Registry logs (pushes, pulls, logins) and metrics to the shared workspace.
resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "diag-acr"
  target_resource_id         = module.acr.id
  log_analytics_workspace_id = data.terraform_remote_state.security.outputs.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
