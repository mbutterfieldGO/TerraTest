output "resource_group_name" {
  description = "Name of the resource group."
  value       = module.resource_group.name
}

output "function_app_name" {
  description = "Name of the function app (use this for code deployment)."
  value       = module.function_app.name
}

output "function_app_default_hostname" {
  description = "Default hostname of the function app."
  value       = module.function_app.default_hostname
}

output "function_app_principal_id" {
  description = "Object ID of the function app's system-assigned managed identity."
  value       = module.function_app.principal_id
}

output "storage_account_name" {
  description = "Name of the function app's storage account."
  value       = module.storage_account.name
}

output "app_insights_name" {
  description = "Name of the Application Insights instance."
  value       = module.monitoring.app_insights_name
}
