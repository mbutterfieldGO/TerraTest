variable "project" {
  description = "Short project name used in resource names (lowercase letters and digits, 2-10 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.project))
    error_message = "project must be 2-10 lowercase letters or digits."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, test, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "test", "uat", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, uat, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus2"
}

variable "location_short" {
  description = "Short region code used in resource names."
  type        = string
  default     = "eus2"
}

variable "storage_replication_type" {
  description = "Replication type for the function app's storage account."
  type        = string
  default     = "LRS"
}

variable "log_retention_in_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "service_plan_sku" {
  description = "App Service plan SKU. Y1 = Consumption, EP1-EP3 = Elastic Premium, B1/S1/P1v3 etc = Dedicated."
  type        = string
  default     = "Y1"
}

variable "runtime_stack" {
  description = "Function runtime stack: dotnet-isolated, dotnet, node, python, java or powershell."
  type        = string
  default     = "dotnet-isolated"
}

variable "runtime_version" {
  description = "Version for the selected runtime stack (e.g. 8.0, 20, 3.11, 17, 7.4)."
  type        = string
  default     = "8.0"
}

variable "always_on" {
  description = "Enable Always On (ignored / forced false on Consumption plans)."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the function app."
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Additional app settings for the function app."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Extra tags merged onto all resources."
  type        = map(string)
  default     = {}
}
