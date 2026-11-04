output "resource_group_name" {
  description = "Compute resource group."
  value       = azurerm_resource_group.compute.name
}

output "web_app_name" {
  description = "Web app name."
  value       = module.app_service.name
}

output "web_app_url" {
  description = "Web app URL."
  value       = "https://${module.app_service.default_hostname}"
}

output "function_app_name" {
  description = "Function app name."
  value       = module.function_app.name
}

output "vm_private_ip" {
  description = "VM private IP."
  value       = module.vm.private_ip_address
}
