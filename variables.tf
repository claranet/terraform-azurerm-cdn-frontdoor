#---------
# Common
variable "client_name" {
  description = "Client name/account used in naming."
  type        = string
}

variable "environment" {
  description = "Project environment."
  type        = string
}

variable "stack" {
  description = "Project stack name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
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
  default     = 120
}

# ------------------
# FrontDoor Endpoint
variable "endpoints" {
  description = "Manages CDN FrontDoor Endpoints."
  type = map(object({
    custom_name = optional(string)
    enabled     = optional(bool, true)
  }))
  default = {}
}

# ------------------
# FrontDoor Origin Groups
variable "origin_groups" {
  description = "Manages CDN FrontDoor Origin Groups."
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
    load_balancing = optional(object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }), {})
  }))
  default = {}
}

# ------------------
# FrontDoor Origins
variable "origins" {
  description = "Manages CDN FrontDoor Origins."
  type = map(object({
    custom_name                    = optional(string)
    origin_group_short_name        = string
    enabled                        = optional(bool, true)
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
# FrontDoor Custom Domains
variable "custom_domains" {
  description = "Manages CDN FrontDoor Custom Domains."
  type = map(object({
    custom_name = optional(string)
    host_name   = string
    dns_zone_id = optional(string)
    tls = optional(object({
      certificate_type        = optional(string, "ManagedCertificate")
      minimum_tls_version     = optional(string, "TLS12")
      cdn_frontdoor_secret_id = optional(string)
    }), {})
  }))
  default = {}

  # validation {
  #   condition = alltrue([
  #     for cd_name, _ in var.custom_domains :
  #     try(
  #       length(regex("[a-zA-Z-]*[-][a-zA-Z-]*", cd_name)) > 0
  #     , false) &&
  #     length(cd_name) >= 2 && length(cd_name) < 260

  #   ])
  #   error_message = "custom domain keys must be between 2 and 260 characters in length, must begin with a letter or number, end with a letter or number and contain only letters, numbers and hyphens"
  # }
}

# ------------------
# FrontDoor Routes
variable "routes" {
  description = "Manages a CDN FrontDoor Routes."
  type = map(object({
    custom_name = optional(string)
    enabled     = optional(bool, true)

    endpoint_short_name     = string
    origin_group_short_name = string
    origins_short_names     = list(string)

    forwarding_protocol = optional(string, "HttpsOnly")
    patterns_to_match   = optional(list(string), ["/*"])
    supported_protocols = optional(list(string), ["Http", "Https"])
    cache = optional(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString")
      query_strings                 = optional(string)
      compression_enabled           = optional(bool, false)
      content_types_to_compress     = optional(list(string))
    }))

    custom_domains_short_names = optional(list(string))
    cdn_frontdoor_origin_path  = optional(string)
    rule_sets_short_names      = optional(list(string))

    https_redirect_enabled = optional(bool, true)
    link_to_default_domain = optional(bool, true)
  }))
  default = {}
}

# ------------------
# FrontDoor Rule Sets
variable "rule_sets" {
  description = "Manages CDN FrontDoor Rule Sets."
  type = map(object({
    custom_name = optional(string)
    rules = optional(map(object({
    })))
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
