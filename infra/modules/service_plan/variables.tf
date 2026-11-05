variable "name" {
  description = "App Service plan name."
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

variable "sku_name" {
  description = "Plan SKU: Y1 (Consumption), EP1/EP2/EP3 (Elastic Premium) or a Dedicated SKU (B1, S1, P1v3...)."
  type        = string
  default     = "Y1"
}

variable "maximum_elastic_worker_count" {
  description = "Maximum burst instances (Elastic Premium plans only)."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
