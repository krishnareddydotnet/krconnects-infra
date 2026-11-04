terraform {
  required_version = ">= 1.17.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.12"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

  # Storage accounts have shared keys disabled, so use Entra ID for storage data-plane calls.
  storage_use_azuread = true
}
