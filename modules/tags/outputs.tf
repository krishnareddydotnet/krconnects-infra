output "tags" {
  description = "Standard tags: environment, owner, project, cost-center, managed-by."
  value       = local.tags
}

output "suffix" {
  description = "Name suffix, for example krconnects-dev-cin-001."
  value       = local.suffix
}

output "resource_group_name" {
  description = "Resource group name for the layer, for example rg-krconnects-network-dev-cin-001."
  value       = local.resource_group_name
}

output "short_suffix" {
  description = "Short name suffix, for example krc-dev-cin-001."
  value       = local.short_suffix
}

output "compact_suffix" {
  description = "Suffix without dashes, for example krcdevcin001."
  value       = local.compact_suffix
}
