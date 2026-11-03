# Non-secret values for test. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "test"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

state_resource_group_name  = "rg-krconnects-tfstate-cin-001"
state_storage_account_name = "stkrctfstatecin001"

vm_size                 = "Standard_B2s_v2"
vm_admin_ssh_public_key = "ssh-ed25519 AAAAREPLACEWITHYOURPUBLICKEY krishna" # REPLACE with your public key
bastion_enabled         = false
app_service_sku         = "B1"
function_app_sku        = "B1"
