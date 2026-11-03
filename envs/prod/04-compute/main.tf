# Two module source styles, side by side:
# - Local module : source = "../../../modules/tags"  (lives in this repo, changes with it)
# - Remote module: source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/<name>?ref=v1.0.0"
#                  (shared repo, pinned to a git tag, upgraded on purpose with a PR)
module "naming" {
  source = "../../../modules/tags"

  project       = "krconnects"
  project_short = "krc"
  environment   = var.environment
  workload      = "compute"
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

# Reads the outputs of layer 03-data from its state file (read-only).
data "terraform_remote_state" "data" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = "tfstate-${var.environment}"
    key                  = "${var.environment}/03-data.tfstate"
    use_azuread_auth     = true
  }
}

resource "azurerm_resource_group" "compute" {
  name     = module.naming.resource_group_name
  location = var.location
  tags     = module.naming.tags
}

module "vm" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/vm?ref=v1.0.0"

  name                 = "vm-${module.naming.suffix}"
  resource_group_name  = azurerm_resource_group.compute.name
  location             = var.location
  size                 = var.vm_size
  subnet_id            = data.terraform_remote_state.network.outputs.subnet_id_vm
  admin_ssh_public_key = var.vm_admin_ssh_public_key
  bastion_enabled      = var.bastion_enabled
  bastion_subnet_id    = data.terraform_remote_state.network.outputs.subnet_id_bastion
  tags                 = module.naming.tags
}

module "app_service" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/app-service?ref=v1.0.0"

  name                       = "app-${module.naming.suffix}"
  service_plan_name          = "asp-${module.naming.suffix}"
  resource_group_name        = azurerm_resource_group.compute.name
  location                   = var.location
  sku_name                   = var.app_service_sku
  vnet_integration_subnet_id = data.terraform_remote_state.network.outputs.subnet_id_app

  app_settings = {
    # No password: the app signs in to SQL with its managed identity.
    "ConnectionStrings__Sql" = "Server=tcp:${data.terraform_remote_state.data.outputs.sql_server_fqdn},1433;Database=${data.terraform_remote_state.data.outputs.sql_database_name};Authentication=Active Directory Default;Encrypt=True;"
    # Real secrets (third-party API keys) come from Key Vault at runtime.
    "Payment__ApiKey" = "@Microsoft.KeyVault(VaultName=${data.terraform_remote_state.security.outputs.key_vault_name};SecretName=payment-api-key)"
  }

  tags = module.naming.tags
}

module "function_app" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/function-app?ref=v1.0.0"

  name                       = "func-${module.naming.suffix}"
  service_plan_name          = "asp-func-${module.naming.suffix}"
  resource_group_name        = azurerm_resource_group.compute.name
  location                   = var.location
  sku_name                   = var.function_app_sku
  storage_account_id         = data.terraform_remote_state.data.outputs.storage_account_id
  storage_account_name       = data.terraform_remote_state.data.outputs.storage_account_name
  vnet_integration_subnet_id = data.terraform_remote_state.network.outputs.subnet_id_func
  tags                       = module.naming.tags
}

# Least privilege: each workload can only read secrets.
resource "azurerm_role_assignment" "app_kv_secrets_user" {
  scope                = data.terraform_remote_state.security.outputs.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_service.principal_id
}

resource "azurerm_role_assignment" "func_kv_secrets_user" {
  scope                = data.terraform_remote_state.security.outputs.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.function_app.principal_id
}

resource "azurerm_role_assignment" "vm_kv_secrets_user" {
  scope                = data.terraform_remote_state.security.outputs.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.vm.principal_id
}

# Web app logs and metrics to the shared workspace.
resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "diag-app"
  target_resource_id         = module.app_service.id
  log_analytics_workspace_id = data.terraform_remote_state.security.outputs.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Function app logs and metrics to the shared workspace.
resource "azurerm_monitor_diagnostic_setting" "func" {
  name                       = "diag-func"
  target_resource_id         = module.function_app.id
  log_analytics_workspace_id = data.terraform_remote_state.security.outputs.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
