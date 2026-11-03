output "resource_group_name" {
  description = "Security resource group."
  value       = azurerm_resource_group.security.name
}

output "key_vault_id" {
  description = "Key Vault ID."
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.key_vault.vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.log_analytics.id
}

output "aks_identity_id" {
  description = "AKS control-plane identity ID."
  value       = module.aks_identity.id
}

output "aks_identity_principal_id" {
  description = "AKS control-plane identity principal ID."
  value       = module.aks_identity.principal_id
}
