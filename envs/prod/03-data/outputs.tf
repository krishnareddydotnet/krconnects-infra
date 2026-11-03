output "resource_group_name" {
  description = "Data resource group."
  value       = azurerm_resource_group.data.name
}

output "storage_account_id" {
  description = "Storage account ID."
  value       = module.storage.id
}

output "storage_account_name" {
  description = "Storage account name."
  value       = module.storage.name
}

output "sql_server_fqdn" {
  description = "SQL server FQDN."
  value       = module.sql.server_fqdn
}

output "sql_database_name" {
  description = "SQL database name."
  value       = module.sql.database_name
}
