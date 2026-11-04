output "resource_group_name" {
  description = "Network resource group."
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "VNet ID."
  value       = module.network.vnet_id
}

output "subnet_id_app" {
  description = "App Service integration subnet."
  value       = module.network.subnet_ids["snet-app-${module.naming.suffix}"]
}

output "subnet_id_func" {
  description = "Function App integration subnet."
  value       = module.network.subnet_ids["snet-func-${module.naming.suffix}"]
}

output "subnet_id_pe" {
  description = "Private endpoint subnet."
  value       = module.network.subnet_ids["snet-pe-${module.naming.suffix}"]
}

output "subnet_id_vm" {
  description = "VM subnet."
  value       = module.network.subnet_ids["snet-vm-${module.naming.suffix}"]
}

output "subnet_id_aks" {
  description = "AKS node subnet."
  value       = module.network.subnet_ids["snet-aks-${module.naming.suffix}"]
}

output "subnet_id_bastion" {
  description = "AzureBastionSubnet."
  value       = module.network.subnet_ids["AzureBastionSubnet"]
}

output "dns_zone_id_key_vault" {
  description = "privatelink.vaultcore.azure.net zone ID."
  value       = module.network.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
}

output "dns_zone_id_blob" {
  description = "privatelink.blob.core.windows.net zone ID."
  value       = module.network.private_dns_zone_ids["privatelink.blob.core.windows.net"]
}

output "dns_zone_id_sql" {
  description = "privatelink.database.windows.net zone ID."
  value       = module.network.private_dns_zone_ids["privatelink.database.windows.net"]
}

output "dns_zone_id_acr" {
  description = "privatelink.azurecr.io zone ID."
  value       = module.network.private_dns_zone_ids["privatelink.azurecr.io"]
}
