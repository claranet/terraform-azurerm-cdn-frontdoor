resource "azurerm_cdn_frontdoor_profile" "frontdoor_profile" {
  name                = local.frontdoor_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  response_timeout_seconds = var.response_timeout_seconds

  tags = merge(local.default_tags, var.extra_tags)
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoint" {
  name                     = local.frontdoor_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id

  enabled = var.endpoint_enabled

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

  enabled = each.value.enabled
  #health_probes_enabled          = each.value.health_probes_enabled
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  host_name                      = each.value.host_name
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
