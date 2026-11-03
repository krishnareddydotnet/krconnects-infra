# Non-secret values for dev. Secrets never go here (they live in Key Vault).
subscription_id = "00000000-0000-0000-0000-000000000000" # REPLACE with your subscription ID
environment     = "dev"
location        = "centralindia"
owner           = "krishna"
cost_center     = "cc-1001"

state_resource_group_name  = "rg-krconnects-tfstate-cin-001"
state_storage_account_name = "stkrctfstatecin001"

storage_replication_type  = "ZRS"
sql_database_sku          = "Basic"
sql_admin_group_name      = "sg-krconnects-sql-admins"
sql_admin_group_object_id = "00000000-0000-0000-0000-000000000000" # REPLACE with the group's object ID
