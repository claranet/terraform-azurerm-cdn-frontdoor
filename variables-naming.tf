# Generic naming variables
variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

# Custom naming override
variable "custom_name" {
  description = "Specifies the name of the FrontDoor Profile."
  type        = string
  default     = ""
}

variable "use_frontdoor_origin_caf_naming" {
  description = "Whether to use Azure CAF naming convention"
  type        = bool
  default     = true
}