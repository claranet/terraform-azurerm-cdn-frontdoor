# ------------------
# CDN FrontDoor

moved {
  from = azurerm_cdn_frontdoor_profile.frontdoor_profile
  to   = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
}

moved {
  from = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint
  to   = azurerm_cdn_frontdoor_endpoint.cdn_frontdoor_endpoint
}

moved {
  from = azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain
  to   = azurerm_cdn_frontdoor_custom_domain.cdn_frontdoor_custom_domain
}

moved {
  from = azurerm_cdn_frontdoor_route.frontdoor_route
  to   = azurerm_cdn_frontdoor_route.cdn_frontdoor_route
}

# ------------------
# CDN FrontDoor Origins

moved {
  from = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group
  to   = azurerm_cdn_frontdoor_origin_group.cdn_frontdoor_origin_group
}

moved {
  from = azurerm_cdn_frontdoor_origin.frontdoor_origin
  to   = azurerm_cdn_frontdoor_origin.cdn_frontdoor_origin
}

# ------------------
# CDN FrontDoor Rules

moved {
  from = azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set
  to   = azurerm_cdn_frontdoor_rule_set.cdn_frontdoor_rule_set
}

moved {
  from = azurerm_cdn_frontdoor_rule.frontdoor_rule
  to   = azurerm_cdn_frontdoor_rule.cdn_frontdoor_rule
}

# ------------------
# CDN FrontDoor Policies

moved {
  from = azurerm_cdn_frontdoor_firewall_policy.frontdoor_firewall_policy
  to   = azurerm_cdn_frontdoor_firewall_policy.cdn_frontdoor_firewall_policy
}

moved {
  from = azurerm_cdn_frontdoor_security_policy.frontdoor_security_policy
  to   = azurerm_cdn_frontdoor_security_policy.cdn_frontdoor_security_policy
}
