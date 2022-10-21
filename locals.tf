locals {
  origins_names_per_route = try({
    for route, parameters in var.routes : route => [
      for origin in parameters.origins_short_names : azurerm_cdn_frontdoor_origin.frontdoor_origin[origin].id
    ]
  }, {})

  custom_domains_per_route = try({
    for route, parameters in var.routes : route => [
      for cd in parameters.custom_domains_short_names : azurerm_cdn_frontdoor_custom_domain.frontdoor_custom_domain[cd].id
    ]
  }, {})

  rule_sets_per_route = try({
    for route, parameters in var.routes : route => [
      for rs in parameters.rule_sets_short_names : azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set[rs].id
    ]
  }, {})

  // each object contains
  // the custom_domain key
  // the endpoint key
  // used for output purposes
  _custom_domain_per_endpoint = try(flatten([
    for route_name, route_meta in var.routes : [
      for cd in route_meta.custom_domains_short_names : {
        custom_domain = cd
        endpoint      = route_meta.endpoint_short_name
      }
    ]
  ]), {})

  // A custom domain and its subdomains can only be associated with a single endpoint at a time
  // There could be possibility to have N endpoints to one custom domain
  // that's why we create map's key according to both these parameter like
  // www.temporairedmp.infogreffe.fr___cfde-app-infogreffe-prod-default-g8e2ezd6e0exhmaf.z01.azurefd.net
  // the "___" part represents the split
  // so at the end we can wee it as
  //
  // the custom domain "www.temporairedmp.infogreffe.fr"
  // is pointing to cfde-app-infogreffe-prod-default-g8e2ezd6e0exhmaf.z01.azurefd.net
  // thus (to be added in the DNS server (custom or managed one via Azure):
  // record name = www.temporairedmp.infogreffe.fr
  // record_value = cfde-app-infogreffe-prod-default-g8e2ezd6e0exhmaf.z01.azurefd.net
  custom_domain_records_cname_per_endpoint = {
    for cdpe in local._custom_domain_per_endpoint : format("%s___%s", var.custom_domains[cdpe.custom_domain].host_name, azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[cdpe.endpoint].host_name) => {
      validation_cname_record_name  = var.custom_domains[cdpe.custom_domain].host_name
      validation_cname_record_value = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[cdpe.endpoint].host_name
    }
  }
}
