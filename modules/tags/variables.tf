variable "project" {
  description = "Project name, for example krconnects."
  type        = string
}

variable "project_short" {
  description = "Short project name for resources with short name limits (Key Vault, Storage), for example krc."
  type        = string
}

variable "environment" {
  description = "Environment: dev, test or prod."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "workload" {
  description = "Layer or workload name used in the resource group name, for example network."
  type        = string
}

variable "location_short" {
  description = "Short region code used in names. cin = Central India."
  type        = string
  default     = "cin"
}

variable "instance" {
  description = "Instance number used in names."
  type        = string
  default     = "001"
}

variable "owner" {
  description = "Owner tag (team or email)."
  type        = string
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
}

variable "extra_tags" {
  description = "Extra tags merged into the standard tags."
  type        = map(string)
  default     = {}
}
