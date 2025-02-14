output "name" {
  description = "The name of the CDN FrontDoor Profile."
  value       = azurerm_cdn_frontdoor_profile.main.name
}

output "id" {
  description = "The ID of the CDN FrontDoor Profile."
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "identity_principal_id" {
  description = "Azure CDN FrontDoor system identity principal ID."
  value       = try(azurerm_cdn_frontdoor_profile.main.identity[0].principal_id, null)
}

output "resource" {
  description = "Azure CDN FrontDoor Profile output object."
  value       = azurerm_cdn_frontdoor_profile.main
}

output "resource_endpoint" {
  description = "Azure CDN FrontDoor endpoints resource output."
  value       = azurerm_cdn_frontdoor_endpoint.main
}

output "resource_origin_group" {
  description = "Azure CDN FrontDoor origin group resource output."
  value       = azurerm_cdn_frontdoor_origin_group.main
}

output "resource_origin" {
  description = "Azure CDN FrontDoor origin resource output."
  value       = azurerm_cdn_frontdoor_origin.main
}

output "resource_custom_domain" {
  description = "Azure CDN FrontDoor custom domain resource output."
  value       = azurerm_cdn_frontdoor_custom_domain.main
}

output "resource_rule_set" {
  description = "Azure CDN FrontDoor rule set resource output."
  value       = azurerm_cdn_frontdoor_rule_set.main
}

output "resource_rule" {
  description = "Azure CDN FrontDoor rule resource output."
  value       = azurerm_cdn_frontdoor_rule.main
}

output "resource_firewall_policy" {
  description = "Azure CDN FrontDoor firewall policy resource output."
  value       = azurerm_cdn_frontdoor_firewall_policy.main
}

output "resource_security_policy" {
  description = "Azure CDN FrontDoor security policy resource output."
  value       = azurerm_cdn_frontdoor_security_policy.main
}

output "resource_route" {
  description = "Azure CDN FrontDoor route resource output."
  value       = azurerm_cdn_frontdoor_route.main
}

output "resource_secret" {
  description = "Azure CDN FrontDoor secret resource output."
  value       = azurerm_cdn_frontdoor_secret.main
}

output "module_diagnostics" {
  description = "Diagnostics Settings module output."
  value       = module.diagnostics
}
