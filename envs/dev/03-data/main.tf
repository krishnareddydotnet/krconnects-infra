# Two module source styles, side by side:
# - Local module : source = "../../../modules/tags"  (lives in this repo, changes with it)
# - Remote module: source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/<name>?ref=v1.0.0"
#                  (shared repo, pinned to a git tag, upgraded on purpose with a PR)
module "naming" {
  source = "../../../modules/tags"

  project       = "krconnects"
  project_short = "krc"
  environment   = var.environment
  workload      = "data"
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

resource "azurerm_resource_group" "data" {
  name     = module.naming.resource_group_name
  location = var.location
  tags     = module.naming.tags
}

module "storage" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/storage-account?ref=v1.0.0"

  name                       = "st${module.naming.compact_suffix}"
  resource_group_name        = azurerm_resource_group.data.name
  location                   = var.location
  account_replication_type   = var.storage_replication_type
  containers                 = ["uploads"]
  private_endpoint_subnet_id = data.terraform_remote_state.network.outputs.subnet_id_pe
  private_dns_zone_id        = data.terraform_remote_state.network.outputs.dns_zone_id_blob
  tags                       = module.naming.tags
}

module "sql" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/sql?ref=v1.0.0"

  server_name                = "sql-${module.naming.suffix}"
  database_name              = "sqldb-${module.naming.suffix}"
  resource_group_name        = azurerm_resource_group.data.name
  location                   = var.location
  database_sku_name          = var.sql_database_sku
  entra_admin_login          = var.sql_admin_group_name
  entra_admin_object_id      = var.sql_admin_group_object_id
  log_analytics_workspace_id = data.terraform_remote_state.security.outputs.log_analytics_workspace_id
  private_endpoint_subnet_id = data.terraform_remote_state.network.outputs.subnet_id_pe
  private_dns_zone_id        = data.terraform_remote_state.network.outputs.dns_zone_id_sql
  tags                       = module.naming.tags
}

# Storage blob logs and metrics to the shared workspace.
resource "azurerm_monitor_diagnostic_setting" "storage-blob" {
  name                       = "diag-storage-blob"
  target_resource_id         = module.storage.blob_service_id
  log_analytics_workspace_id = data.terraform_remote_state.security.outputs.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# SQL database logs and metrics to the shared workspace.
resource "azurerm_monitor_diagnostic_setting" "sql-db" {
  name                       = "diag-sql-db"
  target_resource_id         = module.sql.database_id
  log_analytics_workspace_id = data.terraform_remote_state.security.outputs.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
