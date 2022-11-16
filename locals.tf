locals {
  origins_names_per_route = {
    for route in var.routes : route.name => [
      for origin in route.origins_names : azurerm_cdn_frontdoor_origin.frontdoor_origin[origin].id
    ]
  }

  custom_domains_per_route = {
    for route in var.routes : route.name => [
      for cd in route.custom_domains_names : azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd].id
    ]
  }

  rule_sets_per_route = {
    for route in var.routes : route.name => [
      for rs in route.rule_sets_names : azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set[rs].id
    ]
  }

  rules_per_rule_set = flatten([
    for rule_set in var.rule_sets :
    [
      for rule in rule_set.rules : merge({
        rule_set_name = rule_set.name
      }, rule)
    ]
  ])


  # ------------------
  # Outputs

  endpoints      = try({ for e in var.endpoints : e.name => e }, {})
  origin_groups  = try({ for og in var.origin_groups : og.name => og }, {})
  origins        = try({ for o in var.origins : o.name => o }, {})
  custom_domains = try({ for cd in var.custom_domains : cd.name => cd }, {})
  rule_sets      = try({ for rs in var.rule_sets : rs.name => rs }, {})
  rules          = try({ for r in local.rules_per_rule_set : format("%s.%s", r.rule_set_name, r.name) => r }, {})

}
