# No Azure resources here: this module only builds names and tags,
# so every layer and every environment uses exactly the same standard.
locals {
  tags = merge(
    {
      environment   = var.environment
      owner         = var.owner
      project       = var.project
      "cost-center" = var.cost_center
      "managed-by"  = "terraform"
    },
    var.extra_tags
  )

  # CAF naming: <type>-<suffix>, for example rg-krconnects-dev-cin-001
  suffix = "${var.project}-${var.environment}-${var.location_short}-${var.instance}"

  # One resource group per layer, for example rg-krconnects-network-dev-cin-001
  resource_group_name = "rg-${var.project}-${var.workload}-${var.environment}-${var.location_short}-${var.instance}"

  # For names with a short limit (Key Vault max 24), for example kv-krc-dev-cin-001
  short_suffix = "${var.project_short}-${var.environment}-${var.location_short}-${var.instance}"

  # For names that allow only letters and numbers (Storage, ACR), for example stkrcdevcin001
  compact_suffix = "${var.project_short}${var.environment}${var.location_short}${var.instance}"
}
