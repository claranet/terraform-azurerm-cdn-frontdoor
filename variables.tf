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
  description = "Specifies if this CDN FrontDoor Endpoint is enabled"
  type        = bool
  default     = true
}

# ------------------
# FrontDoor Origin Groups

variable "origin_groups" {
  description = "Manages CDN FrontDoor Origin Groups"
  type = map(object({
    custom_name                                               = optional(string)
    session_affinity_enabled                                  = optional(bool, true)
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)
    health_probe = optional(object({
      interval_in_seconds = number
      path                = string
      protocol            = string
      request_type        = string
    }))
    load_balancing = object({
      additional_latency_in_milliseconds = optional(number, 0)
      sample_size                        = optional(number, 16)
      successful_samples_required        = optional(number, 3)
    })
  }))
  default = {}
}

# ------------------
# FrontDoor Origins
variable "origins" {
  description = "Manages CDN FrontDoor Origins"
  type = map(object({
    custom_name                    = optional(string)
    origin_group_short_name        = string
    health_probes_enabled          = optional(bool, true)
    certificate_name_check_enabled = optional(bool, true)

    host_name          = string
    http_port          = optional(number, 80)
    https_port         = optional(number, 443)
    origin_host_header = optional(string)
    priority           = optional(number, 1)
    weight             = optional(number, 1)

    private_link = optional(object({
      request_message        = optional(string)
      target_type            = optional(string)
      location               = string
      private_link_target_id = string
    }))
  }))
  default = {}
}

# ------------------
# FrontDoor WAF Policy
# variable "frontdoor_waf_policy_id" {
#   description = "Frontdoor WAF Policy ID"
#   type        = string
#   default     = null
# }
