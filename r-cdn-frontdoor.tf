resource "azurerm_cdn_frontdoor_profile" "frontdoor_profile" {
  name                = local.frontdoor_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  response_timeout_seconds = var.response_timeout_seconds

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoint" {
  for_each = var.endpoints

  name                     = coalesce(each.value.custom_name, azurecaf_name.frontdoor_endpoint[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id

  enabled = each.value.enabled

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_cdn_frontdoor_origin_group" "frontdoor_origin_group" {
  for_each = var.origin_groups

  name                     = coalesce(each.value.custom_name, azurecaf_name.frontdoor_origin_group[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id

  session_affinity_enabled = each.value.session_affinity_enabled

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = each.value.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  dynamic "health_probe" {
    for_each = each.value.health_probe == null ? [] : ["enabled"]
    content {
      interval_in_seconds = each.value.health_probe.interval_in_seconds
      path                = each.value.health_probe.path
      protocol            = each.value.health_probe.protocol
      request_type        = each.value.health_probe.request_type
    }
  }

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }
}

resource "azurerm_cdn_frontdoor_origin" "frontdoor_origin" {
  for_each = var.origins

  name                          = coalesce(each.value.custom_name, azurecaf_name.frontdoor_origin[each.key].result)
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group[each.value.origin_group_short_name].id

  enabled                        = each.value.enabled
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  host_name                      = each.value.host_name
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  origin_host_header             = each.value.origin_host_header
  priority                       = each.value.priority
  weight                         = each.value.weight

  dynamic "private_link" {
    for_each = each.value.private_link == null ? [] : ["enabled"]
    content {
      request_message        = each.value.private_link.request_message
      target_type            = each.value.private_link.target_type
      location               = each.value.private_link.location
      private_link_target_id = each.value.private_link.private_link_target_id
    }
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "frontdoor_custom_domain" {
  for_each = var.custom_domains

  name                     = coalesce(each.value.custom_name, azurecaf_name.frontdoor_custom_domain[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.value.host_name

  tls {
    certificate_type        = each.value.tls.certificate_type
    minimum_tls_version     = each.value.tls.minimum_tls_version
    cdn_frontdoor_secret_id = each.value.tls.cdn_frontdoor_secret_id
  }
}

resource "azurerm_cdn_frontdoor_route" "frontdoor_route" {
  for_each = var.routes

  name    = coalesce(each.value.custom_name, azurecaf_name.frontdoor_route[each.key].result)
  enabled = each.value.enabled

  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint[each.value.endpoint_short_name].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group[each.value.origin_group_short_name].id

  cdn_frontdoor_origin_ids = local.origins_names_per_route[each.key]

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

resource "azurerm_cdn_frontdoor_rule_set" "frontdoor_rule_set" {
  for_each = var.rule_sets

  name                     = coalesce(each.value.custom_name, azurecaf_name.frontdoor_rule_set[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

# resource "azurerm_cdn_frontdoor_rule" "example" {
#   depends_on = [azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group, azurerm_cdn_frontdoor_origin.frontdoor_origin]

#   name                      = "examplerule"
#   cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.example.id
#   order                     = 1
#   behavior_on_match         = "Continue"
# }


# NOT NEEDED ?
# resource "azurerm_cdn_frontdoor_custom_domain_association" "frontdoor_custom_domain_association" {
#   for_each = var.custom_domains.id

#   cdn_frontdoor_custom_domain_id                    = each.value.
#   cdn_frontdoor_route_ids = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
# }
