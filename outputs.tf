output "profile_name" {
  description = "The name of the FrontDoor Profile"
  value       = azurerm_cdn_frontdoor_profile.frontdoor_profile.name
}

output "profile_id" {
  description = "The ID of the FrontDoor Profile"
  value       = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

output "endpoints" {
  description = "FrontDoor endpoints outputs."
  value       = { for e in keys(local.endpoints) : e => azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[e] }
}

output "origin_groups" {
  description = "FrontDoor origin groups outputs."
  value       = { for og in keys(local.origin_groups) : og => azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group[og] }
}

output "origins" {
  description = "FrontDoor origins outputs."
  value       = { for o in keys(local.origins) : o => azurerm_cdn_frontdoor_origin.frontdoor_origin[o] }
}

output "custom_domains" {
  description = "FrontDoor custom domains outputs."
  value       = { for cd in keys(local.custom_domains) : cd => azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd] }
}

output "rule_sets" {
  description = "FrontDoor rule sets outputs."
  value       = { for rs in keys(local.rule_sets) : rs => azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set[rs] }
}

output "rules" {
  description = "FrontDoor rules outputs."
  value       = { for r in keys(local.rules) : r => azurerm_cdn_frontdoor_rule.frontdoor_rule[r] }
}
