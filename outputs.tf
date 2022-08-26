output "frontdoor_name" {
  description = "The name of the FrontDoor"
  value       = azurerm_frontdoor.frontdoor.name
}

output "frontdoor_cname" {
  description = "The host that each frontendEndpoint must CNAME to"
  value       = azurerm_frontdoor.frontdoor.cname
}

output "frontdoor_id" {
  description = "The ID of the FrontDoor."
  value       = azurerm_frontdoor.frontdoor.id
}

output "frontdoor_frontend_endpoints" {
  description = "The IDs of the frontend endpoints."
  value       = azurerm_frontdoor.frontdoor.frontend_endpoints
}

output "frontdoor_backend_address_prefixes_ipv4" {
  description = "IPv4 address ranges used by the FrontDoor service backend"
  value       = [for ip in jsondecode(data.external.frontdoor_ips.result.backendPrefixes) : ip if length(regexall("\\.", ip)) > 0]
}

output "frontdoor_backend_address_prefixes_ipv6" {
  description = "IPv6 address ranges used by the FrontDoor service backend"
  value       = [for ip in jsondecode(data.external.frontdoor_ips.result.backendPrefixes) : ip if length(regexall(":", ip)) > 0]
}

output "frontdoor_frontend_address_prefixes_ipv4" {
  description = "IPv4 address ranges used by the FrontDoor service frontend"
  value       = [for ip in jsondecode(data.external.frontdoor_ips.result.frontendPrefixes) : ip if length(regexall("\\.", ip)) > 0]
}

output "frontdoor_frontend_address_prefixes_ipv6" {
  description = "IPv6 address ranges used by the FrontDoor service frontend"
  value       = [for ip in jsondecode(data.external.frontdoor_ips.result.frontendPrefixes) : ip if length(regexall(":", ip)) > 0]
}

output "frontdoor_firstparty_address_prefixes_ipv4" {
  description = "IPv4 address ranges used by the FrontDoor service \"first party\""
  value       = [for ip in jsondecode(data.external.frontdoor_ips.result.firstpartyPrefixes) : ip if length(regexall("\\.", ip)) > 0]
}

output "frontdoor_firstparty_address_prefixes_ipv6" {
  description = "IPv6 address ranges used by the FrontDoor service \"first party\""
  value       = [for ip in jsondecode(data.external.frontdoor_ips.result.firstpartyPrefixes) : ip if length(regexall(":", ip)) > 0]
}
