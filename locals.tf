locals {
  origins_names_per_route = try({
    for route in var.routes : route.name => [
      for origin in route.origins_names : azurerm_cdn_frontdoor_origin.frontdoor_origin[origin].id
    ]
  }, {})

  custom_domains_per_route = try({
    for route in var.routes : route.name => [
      for cd in route.custom_domains_names : azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd].id
    ]
  }, {})

  rule_sets_per_route = try({
    for route in var.routes : route.name => [
      for rs in route.rule_sets_names : azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set[rs].id
    ]
  }, {})

  rules = try(concat([
    for rule_set in var.rule_sets :
    try([
      for rule in rule_set.rules : merge({
        rule_set_name = rule_set.name
      }, rule)
    ], [])
  ]...), [])

  # ------------------
  # Outputs

  # each object contains the custom_domain key the endpoint key
  # custom_domain_per_endpoint = try(flatten([
  #   for route_name, route_meta in var.routes : [
  #     for cd in route_meta.custom_domains_short_names : {
  #       custom_domain = cd
  #       endpoint      = route_meta.endpoint_short_name
  #     }
  #   ]
  # ]), {})

  # A custom domain and its subdomains can only be associated with a single endpoint at a time
  # There could be possibility to have N endpoints to one custom domain
  # that's why we create map's key according to both these parameter like
  # www.temporairedmp.infogreffe.fr___cfde-app-infogreffe-prod-default-g8e2ezd6e0exhmaf.z01.azurefd.net
  # the "___" part represents the split
  # so at the end we can wee it as

  # the custom domain "www.temporairedmp.infogreffe.fr"
  # is pointing to cfde-app-infogreffe-prod-default-g8e2ezd6e0exhmaf.z01.azurefd.net
  # thus (to be added in the DNS server (custom or managed one via Azure):
  # record name = www.temporairedmp.infogreffe.fr
  # record_value = cfde-app-infogreffe-prod-default-g8e2ezd6e0exhmaf.z01.azurefd.net
  # custom_domain_records_cname_per_endpoint = {
  #   for cdpe in local.custom_domain_per_endpoint : format("%s___%s", var.custom_domains[cdpe.custom_domain].host_name, azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[cdpe.endpoint].host_name) => {
  #     validation_cname_record_name  = var.custom_domains[cdpe.custom_domain].host_name
  #     validation_cname_record_value = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[cdpe.endpoint].host_name
  #   }
  # }
}
