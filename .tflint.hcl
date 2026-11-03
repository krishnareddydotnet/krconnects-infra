# TFLint config used by CI. Remote modules are linted in the terraform-modules repo,
# so here we lint this repo's own code and the local tags module.
config {
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.33.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# prevent_destroy cannot be a variable, and dev must be destroyable to save cost.
# Data is protected by soft delete, purge protection, versioning and the state account lock instead.
rule "azurerm_resources_missing_prevent_destroy" {
  enabled = false
}
