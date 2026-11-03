# Non-secret values for dev. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "dev"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

address_space = ["10.10.0.0/16"]

subnet_prefixes = {
  app     = "10.10.1.0/24"
  func    = "10.10.2.0/24"
  pe      = "10.10.3.0/24"
  vm      = "10.10.4.0/24"
  bastion = "10.10.5.0/26"
  aks     = "10.10.8.0/22"
}
