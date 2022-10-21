# output "frontdoor_name" {
#   description = "The name of the FrontDoor"
#   value       = azurerm_frontdoor.frontdoor.name
# }

# output "frontdoor_cname" {
#   description = "The host that each frontendEndpoint must CNAME to"
#   value       = azurerm_frontdoor.frontdoor.cname
# }

# output "frontdoor_id" {
#   description = "The ID of the FrontDoor."
#   value       = azurerm_frontdoor.frontdoor.id
# }

# output "frontdoor_frontend_endpoints" {
#   description = "The IDs of the frontend endpoints."
#   value       = azurerm_frontdoor.frontdoor.frontend_endpoints
# }

# output "frontdoor_backend_address_prefixes_ipv4" {
#   description = "IPv4 address ranges used by the FrontDoor service backend"
#   value       = [for ip in jsondecode(data.external.frontdoor_ips.result.backendPrefixes) : ip if length(regexall("\\.", ip)) > 0]
# }

# output "frontdoor_backend_address_prefixes_ipv6" {
#   description = "IPv6 address ranges used by the FrontDoor service backend"
#   value       = [for ip in jsondecode(data.external.frontdoor_ips.result.backendPrefixes) : ip if length(regexall(":", ip)) > 0]
# }

# output "frontdoor_frontend_address_prefixes_ipv4" {
#   description = "IPv4 address ranges used by the FrontDoor service frontend"
#   value       = [for ip in jsondecode(data.external.frontdoor_ips.result.frontendPrefixes) : ip if length(regexall("\\.", ip)) > 0]
# }

# output "frontdoor_frontend_address_prefixes_ipv6" {
#   description = "IPv6 address ranges used by the FrontDoor service frontend"
#   value       = [for ip in jsondecode(data.external.frontdoor_ips.result.frontendPrefixes) : ip if length(regexall(":", ip)) > 0]
# }

# output "frontdoor_firstparty_address_prefixes_ipv4" {
#   description = "IPv4 address ranges used by the FrontDoor service \"first party\""
#   value       = [for ip in jsondecode(data.external.frontdoor_ips.result.firstpartyPrefixes) : ip if length(regexall("\\.", ip)) > 0]
# }

# output "frontdoor_firstparty_address_prefixes_ipv6" {
#   description = "IPv6 address ranges used by the FrontDoor service \"first party\""
#   value       = [for ip in jsondecode(data.external.frontdoor_ips.result.firstpartyPrefixes) : ip if length(regexall(":", ip)) > 0]
# }







output "custom_domains" {
  value       = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[*]
  description = "Custom domains metadata"
}

output "custom_domains_ssl_validations" {
  value = {
    for cd_name, _ in var.custom_domains : cd_name => {
      id                          = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd_name].id
      expiration_date             = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd_name].expiration_date
      validation_txt_record_value = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd_name].validation_token
      validation_txt_record_name  = join(".", ["_dnsauth", var.custom_domains[cd_name].host_name])
    }
  }
}


output "custom_domains_per_endpoint_validations" {
  value       = local.custom_domain_records_cname_per_endpoint
  description = "CNAME Records to add for each custom domain and endpoint association"
}
