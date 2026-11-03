# Two module source styles, side by side:
# - Local module : source = "../../../modules/tags"  (lives in this repo, changes with it)
# - Remote module: source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/<name>?ref=v1.0.0"
#                  (shared repo, pinned to a git tag, upgraded on purpose with a PR)
module "naming" {
  source = "../../../modules/tags"

  project       = "krconnects"
  project_short = "krc"
  environment   = var.environment
  workload      = "network"
  owner         = var.owner
  cost_center   = var.cost_center
}

resource "azurerm_resource_group" "network" {
  name     = module.naming.resource_group_name
  location = var.location
  tags     = module.naming.tags
}

module "network" {
  source = "git::https://github.com/krishnareddydotnet/terraform-modules.git//modules/network?ref=v1.0.0"

  name                = "vnet-${module.naming.suffix}"
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  address_space       = var.address_space

  subnets = {
    "snet-app-${module.naming.suffix}" = {
      address_prefixes = [var.subnet_prefixes.app]
      delegation       = "Microsoft.Web/serverFarms"
    }
    "snet-func-${module.naming.suffix}" = {
      address_prefixes = [var.subnet_prefixes.func]
      delegation       = "Microsoft.Web/serverFarms"
    }
    "snet-pe-${module.naming.suffix}" = {
      address_prefixes = [var.subnet_prefixes.pe]
    }
    "snet-vm-${module.naming.suffix}" = {
      address_prefixes = [var.subnet_prefixes.vm]
    }
    "snet-aks-${module.naming.suffix}" = {
      address_prefixes = [var.subnet_prefixes.aks]
    }
    # Fixed name required by Azure. Bastion needs its own NSG rules, so no module NSG.
    "AzureBastionSubnet" = {
      address_prefixes = [var.subnet_prefixes.bastion]
      nsg_enabled      = false
    }
  }

  private_dns_zone_names = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net",
    "privatelink.azurecr.io",
  ]

  tags = module.naming.tags
}
