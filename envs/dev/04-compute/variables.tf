variable "subscription_id" {
  description = "Azure subscription ID for this environment."
  type        = string
}

variable "environment" {
  description = "Environment: dev, test or prod."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "centralindia"
}

variable "owner" {
  description = "Owner tag (team or email)."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
}

variable "state_resource_group_name" {
  description = "Resource group of the Terraform state storage account."
  type        = string
}

variable "state_storage_account_name" {
  description = "Terraform state storage account, used to read earlier layers' outputs."
  type        = string
}

variable "vm_size" {
  description = "VM size."
  type        = string
}

variable "vm_admin_ssh_public_key" {
  description = "SSH public key for the VM admin (a public key is not a secret)."
  type        = string
}

variable "bastion_enabled" {
  description = "Create Azure Bastion. PREMIUM COST (billed hourly), keep false unless needed."
  type        = bool
  default     = false
}

variable "app_service_sku" {
  description = "App Service plan SKU (B1 or higher for VNet integration)."
  type        = string
}

variable "function_app_sku" {
  description = "Function App plan SKU (B1 or higher for VNet integration)."
  type        = string
}
