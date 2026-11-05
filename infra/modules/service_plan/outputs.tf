output "id" {
  description = "App Service plan ID."
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "App Service plan name."
  value       = azurerm_service_plan.this.name
}
