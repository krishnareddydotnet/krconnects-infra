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

variable "key_vault_soft_delete_days" {
  description = "Key Vault soft delete retention (7-90 days)."
  type        = number
}

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
}

variable "log_daily_quota_gb" {
  description = "Log Analytics daily ingestion cap in GB."
  type        = number
}
