#---------
# Common
variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

# ------------------
# FrontDoor Profile

variable "sku_name" {
  description = "Specifies the SKU for this CDN FrontDoor Profile. Possible values include `Standard_AzureFrontDoor` and `Premium_AzureFrontDoor`."
  type        = string
  default     = "Standard_AzureFrontDoor"
}

variable "response_timeout_seconds" {
  description = "Specifies the maximum response timeout in seconds. Possible values are between `16` and `240` seconds (inclusive)."
  type        = number
  default     = null
}

# ------------------
# FrontDoor Endpoint

variable "endpoint_enabled" {
  description = "Specifies if this CDN FrontDoor Endpoint is enabled?"
  type        = bool
  default     = true
}



# ------------------
# FrontDoor WAF Policy
variable "frontdoor_waf_policy_id" {
  description = "Frontdoor WAF Policy ID"
  type        = string
  default     = null
}
