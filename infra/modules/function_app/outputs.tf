output "id" {
  description = "Function app ID."
  value       = azurerm_linux_function_app.this.id
}

output "name" {
  description = "Function app name."
  value       = azurerm_linux_function_app.this.name
}

output "default_hostname" {
  description = "Default hostname."
  value       = azurerm_linux_function_app.this.default_hostname
}

output "principal_id" {
  description = "Object ID of the system-assigned managed identity."
  value       = azurerm_linux_function_app.this.identity[0].principal_id
}
