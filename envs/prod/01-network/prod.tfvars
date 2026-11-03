# Non-secret values for prod. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "prod"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

address_space = ["10.30.0.0/16"]

subnet_prefixes = {
  app     = "10.30.1.0/24"
  func    = "10.30.2.0/24"
  pe      = "10.30.3.0/24"
  vm      = "10.30.4.0/24"
  bastion = "10.30.5.0/26"
  aks     = "10.30.8.0/22"
}
