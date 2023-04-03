resource "azurerm_cdn_frontdoor_rule_set" "cdn_frontdoor_rule_set" {
  for_each = {
    for rule_set in var.rule_sets : rule_set.name => rule_set
  }

  name = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_rule_set[each.key].result)

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile.id
}

resource "azurerm_cdn_frontdoor_rule" "cdn_frontdoor_rule" {
  for_each = {
    for rule in local.rules_per_rule_set : format("%s.%s", rule.rule_set_name, rule.name) => rule
  }

  name = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_rule[each.key].result)

  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.cdn_frontdoor_rule_set[each.value.rule_set_name].id

  order             = each.value.order
  behavior_on_match = each.value.behavior_on_match

  actions {
    dynamic "url_rewrite_action" {
      for_each = each.value.actions.url_rewrite_action
      iterator = action
      content {
        source_pattern          = action.value.source_pattern
        destination             = action.value.destination
        preserve_unmatched_path = action.value.preserve_unmatched_path
      }
    }
    dynamic "url_redirect_action" {
      for_each = each.value.actions.url_redirect_action
      iterator = action
      content {
        redirect_type        = action.value.redirect_type
        destination_hostname = action.value.destination_hostname
        redirect_protocol    = action.value.redirect_protocol
        destination_path     = action.value.destination_path
        query_string         = action.value.query_string
        destination_fragment = action.value.destination_fragment
      }
    }
    dynamic "route_configuration_override_action" {
      for_each = each.value.actions.route_configuration_override_action
      iterator = action
      content {
        cache_duration                = action.value.cache_duration
        cdn_frontdoor_origin_group_id = action.value.cdn_frontdoor_origin_group_id
        forwarding_protocol           = action.value.forwarding_protocol
        query_string_caching_behavior = action.value.query_string_caching_behavior
        query_string_parameters       = action.value.query_string_parameters
        compression_enabled           = action.value.compression_enabled
        cache_behavior                = action.value.cache_behavior
      }
    }
    dynamic "request_header_action" {
      for_each = each.value.actions.request_header_action
      iterator = action
      content {
        header_action = action.value.header_action
        header_name   = action.value.header_name
        value         = action.value.value
      }
    }
    dynamic "response_header_action" {
      for_each = each.value.actions.response_header_action
      iterator = action
      content {
        header_action = action.value.header_action
        header_name   = action.value.header_name
        value         = action.value.value
      }
    }
  }

  dynamic "conditions" {
    for_each = each.value.conditions[*]
    content {
      dynamic "remote_address_condition" {
        for_each = each.value.conditions.remote_address_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
        }
      }
      dynamic "request_method_condition" {
        for_each = each.value.conditions.request_method_condition
        iterator = condition
        content {
          match_values     = condition.value.match_values
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
        }
      }
      dynamic "query_string_condition" {
        for_each = each.value.conditions.query_string_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "post_args_condition" {
        for_each = each.value.conditions.post_args_condition
        iterator = condition
        content {
          post_args_name   = condition.value.post_args_name
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "request_uri_condition" {
        for_each = each.value.conditions.request_uri_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "request_header_condition" {
        for_each = each.value.conditions.request_header_condition
        iterator = condition
        content {
          header_name      = condition.value.header_name
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "request_body_condition" {
        for_each = each.value.conditions.request_body_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          match_values     = condition.value.match_values
          negate_condition = condition.value.negate_condition
          transforms       = condition.value.transforms
        }
      }
      dynamic "request_scheme_condition" {
        for_each = each.value.conditions.request_scheme_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
        }
      }
      dynamic "url_path_condition" {
        for_each = each.value.conditions.url_path_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "url_file_extension_condition" {
        for_each = each.value.conditions.url_file_extension_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "url_filename_condition" {
        for_each = each.value.conditions.url_filename_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          match_values     = condition.value.match_values
          negate_condition = condition.value.negate_condition
          transforms       = condition.value.transforms
        }
      }
      dynamic "http_version_condition" {
        for_each = each.value.conditions.http_version_condition
        iterator = condition
        content {
          match_values     = condition.value.match_values
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
        }
      }
      dynamic "cookies_condition" {
        for_each = each.value.conditions.cookies_condition
        iterator = condition
        content {
          cookie_name      = condition.value.cookie_name
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
          transforms       = condition.value.transforms
        }
      }
      dynamic "is_device_condition" {
        for_each = each.value.conditions.is_device_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
        }
      }
      dynamic "socket_address_condition" {
        for_each = each.value.conditions.socket_address_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
        }
      }
      dynamic "client_port_condition" {
        for_each = each.value.conditions.client_port_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
          match_values     = condition.value.match_values
        }
      }
      dynamic "server_port_condition" {
        for_each = each.value.conditions.server_port_condition
        iterator = condition
        content {
          operator         = condition.value.operator
          match_values     = condition.value.match_values
          negate_condition = condition.value.negate_condition
        }
      }
      dynamic "host_name_condition" {
        for_each = each.value.conditions.host_name_condition
        iterator = condition
        content {
          operator     = condition.value.operator
          match_values = condition.value.match_values
          transforms   = condition.value.transforms
        }
      }
      dynamic "ssl_protocol_condition" {
        for_each = each.value.conditions.ssl_protocol_condition
        iterator = condition
        content {
          match_values     = condition.value.match_values
          operator         = condition.value.operator
          negate_condition = condition.value.negate_condition
        }
      }
    }
  }

  depends_on = [
    azurerm_cdn_frontdoor_origin_group.cdn_frontdoor_origin_group,
    azurerm_cdn_frontdoor_origin.cdn_frontdoor_origin,
  ]
}
