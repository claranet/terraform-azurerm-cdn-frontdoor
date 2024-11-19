locals {
  origins_names_per_route = {
    for route in var.routes : route.name => [
      for origin in route.origins_names : azurerm_cdn_frontdoor_origin.main[origin].id
    ]
  }

  custom_domains_per_route = {
    for route in var.routes : route.name => [
      for cd in route.custom_domains_names : azurerm_cdn_frontdoor_custom_domain.main[cd].id
    ]
  }

  rule_sets_per_route = {
    for route in var.routes : route.name => [
      for rs in route.rule_sets_names : azurerm_cdn_frontdoor_rule_set.main[rs].id
    ]
  }

  rules_per_rule_set = flatten([
    for rule_set in var.rule_sets : [
      for rule in rule_set.rules : merge({ rule_set_name = rule_set.name }, rule)
    ]
  ])
}
