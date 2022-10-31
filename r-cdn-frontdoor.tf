resource "azurerm_cdn_frontdoor_profile" "frontdoor_profile" {
  name                = local.frontdoor_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  response_timeout_seconds = var.response_timeout_seconds

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoint" {
  for_each = { for endpoint in var.endpoints : endpoint.name => endpoint }

  name                     = coalesce(each.value.custom_resource_name, azurecaf_name.frontdoor_endpoint[each.value.name].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id

  enabled = each.value.enabled

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_cdn_frontdoor_custom_domain" "frontdoor_custom_domain" {
  for_each = { for custom_domain in var.custom_domains : custom_domain.name => custom_domain }

  name                     = coalesce(each.value.custom_resource_name, azurecaf_name.frontdoor_custom_domain[each.value.name].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.value.host_name

  dynamic "tls" {
    for_each = each.value.tls == null ? [] : ["enabled"]
    content {
      certificate_type        = each.value.tls.certificate_type
      minimum_tls_version     = each.value.tls.minimum_tls_version
      cdn_frontdoor_secret_id = each.value.tls.cdn_frontdoor_secret_id
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "frontdoor_route" {
  for_each = { for route in var.routes : route.name => route }

  name    = coalesce(each.value.custom_resource_name, azurecaf_name.frontdoor_route[each.value.name].result)
  enabled = each.value.enabled

  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[each.value.endpoint_name].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group[each.value.origin_group_name].id

  cdn_frontdoor_origin_ids = local.origins_names_per_route[each.value.name]

  forwarding_protocol = each.value.forwarding_protocol
  patterns_to_match   = each.value.patterns_to_match
  supported_protocols = each.value.supported_protocols

  dynamic "cache" {
    for_each = each.value.cache == null ? [] : ["enabled"]
    content {
      query_string_caching_behavior = each.value.cache.query_string_caching_behavior
      query_strings                 = each.value.cache.query_strings
      compression_enabled           = each.value.cache.compression_enabled
      content_types_to_compress     = each.value.cache.content_types_to_compress
    }
  }

  cdn_frontdoor_custom_domain_ids = try(local.custom_domains_per_route[each.key], [])
  cdn_frontdoor_origin_path       = each.value.cdn_frontdoor_origin_path
  cdn_frontdoor_rule_set_ids      = try(local.rule_sets_per_route[each.key], [])

  https_redirect_enabled = each.value.https_redirect_enabled
  link_to_default_domain = each.value.link_to_default_domain
}
