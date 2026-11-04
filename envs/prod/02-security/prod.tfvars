# Non-secret values for prod. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "prod"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

state_resource_group_name  = "rg-krconnects-tfstate-cin-001"
state_storage_account_name = "stkrctfstatecin001"

key_vault_soft_delete_days = 90
log_retention_days         = 90
log_daily_quota_gb         = 10
