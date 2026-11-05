variable "name" {
  description = "Function app name (globally unique)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "service_plan_id" {
  description = "ID of the App Service plan hosting the function app."
  type        = string
}

variable "storage_account_name" {
  description = "Storage account used by the Functions host."
  type        = string
}

variable "storage_account_access_key" {
  description = "Access key for the Functions host storage account."
  type        = string
  sensitive   = true
}

variable "application_insights_connection_string" {
  description = "Application Insights connection string."
  type        = string
  sensitive   = true
}

variable "runtime_stack" {
  description = "dotnet-isolated, dotnet, node, python, java or powershell."
  type        = string

  validation {
    condition     = contains(["dotnet-isolated", "dotnet", "node", "python", "java", "powershell"], var.runtime_stack)
    error_message = "runtime_stack must be one of: dotnet-isolated, dotnet, node, python, java, powershell."
  }
}

variable "runtime_version" {
  description = "Version for the runtime stack (e.g. 8.0, 20, 3.11, 17, 7.4)."
  type        = string
}

variable "always_on" {
  description = "Enable Always On (not supported on Consumption plans)."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public network access."
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Additional app settings."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
