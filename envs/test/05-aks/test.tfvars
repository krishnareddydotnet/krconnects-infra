# Non-secret values for test. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "test"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

state_resource_group_name  = "rg-krconnects-tfstate-cin-001"
state_storage_account_name = "stkrctfstatecin001"

acr_sku                             = "Premium"
aks_sku_tier                        = "Free"
aks_private_cluster_enabled         = false
aks_api_server_authorized_ip_ranges = ["203.0.113.10/32"]                      # REPLACE with your public IP
aks_admin_group_object_ids          = ["00000000-0000-0000-0000-000000000000"] # REPLACE with your AKS admin group object ID
aks_system_node_count               = 1
aks_user_node_count                 = 1
aks_zones                           = []
