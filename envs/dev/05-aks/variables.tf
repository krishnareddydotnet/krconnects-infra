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

variable "acr_sku" {
  description = "ACR SKU. Premium is needed for the private endpoint (extra cost)."
  type        = string
}

variable "aks_sku_tier" {
  description = "AKS tier: Free (no SLA) or Standard (SLA, extra cost)."
  type        = string
}

variable "aks_private_cluster_enabled" {
  description = "Private API server (reachable only from the VNet)."
  type        = bool
}

variable "aks_api_server_authorized_ip_ranges" {
  description = "Public IPs allowed to reach a public API server, for example [\"203.0.113.10/32\"]."
  type        = list(string)
  default     = []
}

variable "aks_admin_group_object_ids" {
  description = "Entra ID group object IDs with cluster admin."
  type        = list(string)
}

variable "aks_system_node_count" {
  description = "System node count."
  type        = number
}

variable "aks_user_node_count" {
  description = "User node count."
  type        = number
}

variable "aks_zones" {
  description = "Availability zones for node pools."
  type        = list(string)
  default     = []
}
