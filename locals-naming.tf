locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  name = coalesce(var.custom_name, data.azurecaf_name.cdn_frontdoor_profile.result)
}
