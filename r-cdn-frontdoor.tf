resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = local.name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  response_timeout_seconds = var.response_timeout_seconds

  tags = merge(local.default_tags, var.extra_tags)
}

moved {
  from = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
  to   = azurerm_cdn_frontdoor_profile.main
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  for_each = try({ for endpoint in var.endpoints : endpoint.name => endpoint }, {})

  name                     = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_endpoint[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  enabled = each.value.enabled

  tags = merge(local.default_tags, var.extra_tags)
}

moved {
  from = azurerm_cdn_frontdoor_endpoint.cdn_frontdoor_endpoint
  to   = azurerm_cdn_frontdoor_endpoint.main
}

resource "azurerm_cdn_frontdoor_custom_domain" "main" {
  for_each = try({ for custom_domain in var.custom_domains : custom_domain.name => custom_domain }, {})

  name                     = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_custom_domain[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.value.host_name

  dynamic "tls" {
    for_each = each.value.tls == null ? [] : ["enabled"]
    content {
      certificate_type        = each.value.tls.certificate_type
      minimum_tls_version     = each.value.tls.minimum_tls_version
      cdn_frontdoor_secret_id = try(coalesce(each.value.tls.key_vault_certificate_id, each.value.tls.cdn_frontdoor_secret_id), null) == null ? each.value.tls.cdn_frontdoor_secret_id : try(azurerm_cdn_frontdoor_secret.main[each.value.name].id, null)
    }
  }
}

moved {
  from = azurerm_cdn_frontdoor_custom_domain.cdn_frontdoor_custom_domain
  to   = azurerm_cdn_frontdoor_custom_domain.main
}

resource "azurerm_cdn_frontdoor_route" "main" {
  for_each = try({ for route in var.routes : route.name => route }, {})

  name    = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_route[each.key].result)
  enabled = each.value.enabled

  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main[each.value.endpoint_name].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main[each.value.origin_group_name].id

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
  cdn_frontdoor_origin_path       = each.value.origin_path
  cdn_frontdoor_rule_set_ids      = try(local.rule_sets_per_route[each.key], [])

  https_redirect_enabled = each.value.https_redirect_enabled
  link_to_default_domain = each.value.link_to_default_domain
}

moved {
  from = azurerm_cdn_frontdoor_route.cdn_frontdoor_route
  to   = azurerm_cdn_frontdoor_route.main
}

resource "azurerm_cdn_frontdoor_secret" "main" {
  for_each                 = try({ for custom_domain in var.custom_domains : custom_domain.name => custom_domain if custom_domain.tls.key_vault_certificate_id != null }, {})
  name                     = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_custom_domain[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  dynamic "secret" {
    for_each = each.value.tls.certificate_type == "ManagedCertificate" ? [] : ["enabled"]
    content {
      customer_certificate {
        key_vault_certificate_id = each.value.tls.key_vault_certificate_id
      }
    }
  }
}

moved {
  from = azurerm_cdn_frontdoor_secret.cdn_frontdoor_secret
  to   = azurerm_cdn_frontdoor_secret.main
}
