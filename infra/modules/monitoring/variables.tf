variable "log_analytics_name" {
  description = "Log Analytics workspace name."
  type        = string
}

variable "app_insights_name" {
  description = "Application Insights name."
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

variable "retention_in_days" {
  description = "Log Analytics retention (30-730 days)."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730."
  }
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
