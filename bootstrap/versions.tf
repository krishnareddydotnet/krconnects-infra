terraform {
  required_version = ">= 1.17.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.12"
    }
  }

  # No backend block on purpose: bootstrap creates the remote-state storage,
  # so it cannot store its own state there yet. It uses local state (see README).
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

  # Shared keys are disabled on the state account, so use Entra ID for data-plane calls.
  storage_use_azuread = true
}
