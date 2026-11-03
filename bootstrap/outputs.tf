output "resource_group_name" {
  description = "State resource group (use in backend.tf)."
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "State storage account (use in backend.tf)."
  value       = azurerm_storage_account.state.name
}

output "storage_account_id" {
  description = "State storage account ID (scope for role assignments)."
  value       = azurerm_storage_account.state.id
}

output "container_names" {
  description = "State container per environment."
  value       = [for container in azurerm_storage_container.state : container.name]
}
