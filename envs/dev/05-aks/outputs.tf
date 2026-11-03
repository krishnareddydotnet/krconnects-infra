output "resource_group_name" {
  description = "AKS resource group."
  value       = azurerm_resource_group.aks.name
}

output "aks_name" {
  description = "AKS cluster name."
  value       = module.aks.name
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL."
  value       = module.aks.oidc_issuer_url
}

output "acr_login_server" {
  description = "ACR login server."
  value       = module.acr.login_server
}

output "orders_identity_client_id" {
  description = "Client ID for the orders-sa annotation azure.workload.identity/client-id."
  value       = module.orders_identity.client_id
}
