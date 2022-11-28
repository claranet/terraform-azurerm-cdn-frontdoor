output "profile_name" {
  description = "The name of the CDN FrontDoor Profile."
  value       = azurerm_cdn_frontdoor_profile.frontdoor_profile.name
}

output "profile_id" {
  description = "The ID of the CDN FrontDoor Profile."
  value       = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

output "endpoints" {
  description = "CDN FrontDoor endpoints outputs."
  value       = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint
}

output "origin_groups" {
  description = "CDN FrontDoor origin groups outputs."
  value       = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group
}

output "origins" {
  description = "CDN FrontDoor origins outputs."
  value       = azurerm_cdn_frontdoor_origin.frontdoor_origin
}

output "custom_domains" {
  description = "CDN FrontDoor custom domains outputs."
  value       = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain
}

output "rule_sets" {
  description = "CDN FrontDoor rule sets outputs."
  value       = azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set
}

output "rules" {
  description = "CDN FrontDoor rules outputs."
  value       = azurerm_cdn_frontdoor_rule.frontdoor_rule
}

output "firewall_policies" {
  description = "CDN FrontDoor firewall policies outputs."
  value       = azurerm_cdn_frontdoor_firewall_policy.frontdoor_firewall_policy
}

output "security_policies" {
  description = "CDN FrontDoor security policies outputs."
  value       = azurerm_cdn_frontdoor_security_policy.frontdoor_security_policy
}
