variable "subscription_id" {
  description = "Azure subscription ID that holds the Terraform state."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Resource group for the state storage account."
  type        = string
  default     = "rg-krconnects-tfstate-cin-001"
}

variable "storage_account_name" {
  description = "State storage account name (globally unique, 3-24 lowercase letters/numbers)."
  type        = string
  default     = "stkrctfstatecin001"
}

variable "environments" {
  description = "One state container per environment, so each pipeline identity can access only its own state."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "soft_delete_days" {
  description = "Days a deleted state blob or container can be restored."
  type        = number
  default     = 30
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "krishna"
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
  default     = "cc-1001"
}
