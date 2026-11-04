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

variable "storage_replication_type" {
  description = "Storage replication: LRS, ZRS, GRS, GZRS."
  type        = string
}

variable "sql_database_sku" {
  description = "SQL database SKU, for example Basic, S0, GP_S_Gen5_1."
  type        = string
}

variable "sql_admin_group_name" {
  description = "Entra ID group that is SQL admin (display name)."
  type        = string
}

variable "sql_admin_group_object_id" {
  description = "Object ID of that Entra ID group (not a secret)."
  type        = string
}
