# tags (local module)

Builds the standard tags and CAF name suffixes. Creates no Azure resources.

## Usage
```hcl
module "naming" {
  source = "../../../modules/tags"

  project       = "krconnects"
  project_short = "krc"
  environment   = "dev"
  workload      = "network"
  owner         = "krishna"
  cost_center   = "cc-1001"
}

# module.naming.resource_group_name  -> rg-krconnects-network-dev-cin-001
# "vnet-${module.naming.suffix}"      -> vnet-krconnects-dev-cin-001
# "kv-${module.naming.short_suffix}"  -> kv-krc-dev-cin-001
# "st${module.naming.compact_suffix}" -> stkrcdevcin001
```

## Outputs
`tags`, `resource_group_name`, `suffix`, `short_suffix`, `compact_suffix`.

Why local? It is specific to this project and changes with it. Reusable Azure modules live in
[terraform-modules](https://github.com/krishnareddydotnet/terraform-modules) and are pinned by tag.
