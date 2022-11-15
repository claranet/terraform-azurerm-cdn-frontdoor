output "frontdoor_profile_name" {
  description = "The name of the FrontDoor Profile"
  value       = azurerm_cdn_frontdoor_profile.frontdoor_profile.name
}

output "frontdoor_profile_id" {
  description = "The ID of the FrontDoor Profile"
  value       = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

output "frontdoor_endpoints" {
  description = "The IDs of the frontend endpoints."
  value       = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint
}


# output "custom_domains" {
#   value       = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[*]
#   description = "Custom domains metadata"
# }

# output "custom_domains_ssl_validations" {
#   value = {
#     for cd_name, _ in var.custom_domains : cd_name => {
#       id                          = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd_name].id
#       expiration_date             = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd_name].expiration_date
#       validation_txt_record_value = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd_name].validation_token
#       validation_txt_record_name  = join(".", ["_dnsauth", var.custom_domains[cd_name].host_name])
#     }
#   }
# }

# output "custom_domains_per_endpoint_validations" {
#   value       = local.custom_domain_records_cname_per_endpoint
#   description = "CNAME Records to add for each custom domain and endpoint association"
# }
