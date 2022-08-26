locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  frontdoor_profile_name                   = coalesce(var.frontdoor_profile_name, azurecaf_name.frontdoor_profile.result)
  frontdoor_endpoint_name                  = coalesce(var.frontdoor_endpoint_name, azurecaf_name.frontdoor_endpoint.result)
  default_frontend_endpoint_hostname       = try(azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.host_name, format("%s.azureedge.net", local.frontdoor_endpoint_name))
  default_backend_pool_health_probe_name   = azurecaf_name.frontdoor_probe.result
  default_backend_pool_load_balancing_name = azurecaf_name.frontdoor_lb.result
}
