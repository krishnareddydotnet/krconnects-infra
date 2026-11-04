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

variable "address_space" {
  description = "VNet address space. Use a different range per environment so they can be peered later."
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "Subnet ranges."
  type = object({
    app     = string
    func    = string
    pe      = string
    vm      = string
    aks     = string
    bastion = string
  })
}
