data "azurerm_client_config" "current" {}

locals {
  tags = {
    environment   = "shared"
    owner         = var.owner
    project       = "krconnects"
    "cost-center" = var.cost_center
    "managed-by"  = "terraform"
  }
}

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "state" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  # RBAC only: no account keys or SAS. Pipelines use OIDC + "Storage Blob Data" roles,
  # and the backend uses use_azuread_auth = true.
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  # Public endpoint stays on so GitHub-hosted runners can reach it (access still needs Entra ID + RBAC).
  # With self-hosted runners in a VNet, add a private endpoint and set this to "Disabled".
  public_network_access = "Enabled"

  blob_properties {
    # State history: every write creates a version, so a corrupted state can be rolled back.
    versioning_enabled = true

    delete_retention_policy {
      days = var.soft_delete_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_days
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "state" {
  for_each = toset(var.environments)

  name                  = "tfstate-${each.value}"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

# The person running bootstrap also needs data access to run Terraform locally.
resource "azurerm_role_assignment" "deployer_blob" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Stops anyone (including Terraform) deleting the state account by mistake.
resource "azurerm_management_lock" "state" {
  name       = "lock-cannot-delete"
  scope      = azurerm_storage_account.state.id
  lock_level = "CanNotDelete"
  notes      = "Holds Terraform state for all environments."
}
