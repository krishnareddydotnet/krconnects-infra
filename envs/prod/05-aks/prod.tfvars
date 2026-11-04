# Non-secret values for prod. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "prod"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

state_resource_group_name  = "rg-krconnects-tfstate-cin-001"
state_storage_account_name = "stkrctfstatecin001"

acr_sku                             = "Premium"
aks_sku_tier                        = "Standard"
aks_private_cluster_enabled         = true
aks_api_server_authorized_ip_ranges = []
aks_admin_group_object_ids          = ["00000000-0000-0000-0000-000000000000"] # REPLACE with your AKS admin group object ID
aks_system_node_count               = 3
aks_user_node_count                 = 2
aks_zones                           = ["1", "2", "3"]
