locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  frontdoor_profile_name  = coalesce(var.frontdoor_profile_name, azurecaf_name.frontdoor_profile.result)
  frontdoor_endpoint_name = coalesce(var.frontdoor_endpoint_name, azurecaf_name.frontdoor_endpoint.result)
}
