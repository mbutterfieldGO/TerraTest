project        = "funcapp"
environment    = "dev"
location       = "eastus2"
location_short = "eus2"

# Consumption plan for dev
service_plan_sku         = "Y1"
storage_replication_type = "LRS"
log_retention_in_days    = 30

runtime_stack   = "dotnet-isolated"
runtime_version = "8.0"

app_settings = {
  "ENVIRONMENT" = "dev"
}

tags = {
  cost_center = "engineering"
}
