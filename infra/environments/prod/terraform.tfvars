project        = "funcapp"
environment    = "prod"
location       = "eastus2"
location_short = "eus2"

# Elastic Premium for prod: no cold starts, VNet-capable
service_plan_sku         = "EP1"
always_on                = true
storage_replication_type = "ZRS"
log_retention_in_days    = 90

runtime_stack   = "dotnet-isolated"
runtime_version = "8.0"

app_settings = {
  "ENVIRONMENT" = "prod"
}

tags = {
  cost_center = "engineering"
  criticality = "high"
}
