resource "azurerm_cdn_frontdoor_rule_set" "frontdoor_rule_set" {
  for_each = { for rule_set in var.rule_sets : rule_set.name => rule_set }

  name                     = coalesce(each.value.custom_resource_name, data.azurecaf_name.frontdoor_rule_set[each.key].result)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
}

resource "azurerm_cdn_frontdoor_rule" "frontdoor_rule" {
  depends_on = [azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group, azurerm_cdn_frontdoor_origin.frontdoor_origin]

  for_each = { for rule in local.rules_per_rule_set : format("%s.%s", rule.rule_set_name, rule.name) => rule }

  name                      = coalesce(each.value.custom_resource_name, data.azurecaf_name.frontdoor_rule[each.key].result)
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.frontdoor_rule_set[each.value.rule_set_name].id
  order                     = each.value.order
  behavior_on_match         = each.value.behavior_on_match

  actions {
    dynamic "url_rewrite_action" {
      for_each = each.value.actions.url_rewrite_action == null ? [] : ["enabled"]
      content {
        source_pattern          = each.value.actions.url_rewrite_action.source_pattern
        destination             = each.value.actions.url_rewrite_action.destination
        preserve_unmatched_path = each.value.actions.url_rewrite_action.preserve_unmatched_path
      }
    }
    dynamic "url_redirect_action" {
      for_each = each.value.actions.url_redirect_action == null ? [] : ["enabled"]
      content {
        redirect_type        = each.value.actions.url_redirect_action.redirect_type
        destination_hostname = each.value.actions.url_redirect_action.destination_hostname
        redirect_protocol    = each.value.actions.url_redirect_action.redirect_protocol
        destination_path     = each.value.actions.url_redirect_action.destination_path
        query_string         = each.value.actions.url_redirect_action.query_string
        destination_fragment = each.value.actions.url_redirect_action.destination_fragment
      }
    }
    dynamic "route_configuration_override_action" {
      for_each = each.value.actions.route_configuration_override_action == null ? [] : ["enabled"]
      content {
        cache_duration                = each.value.actions.route_configuration_override_action.cache_duration
        cdn_frontdoor_origin_group_id = each.value.actions.route_configuration_override_action.cdn_frontdoor_origin_group_id
        forwarding_protocol           = each.value.actions.route_configuration_override_action.forwarding_protocol
        query_string_caching_behavior = each.value.actions.route_configuration_override_action.query_string_caching_behavior
        query_string_parameters       = each.value.actions.route_configuration_override_action.query_string_parameters
        compression_enabled           = each.value.actions.route_configuration_override_action.compression_enabled
        cache_behavior                = each.value.actions.route_configuration_override_action.cache_behavior
      }
    }
    dynamic "request_header_action" {
      for_each = each.value.actions.request_header_action == null ? [] : ["enabled"]
      content {
        header_action = each.value.actions.request_header_action.header_action
        header_name   = each.value.actions.request_header_action.header_name
        value         = each.value.actions.request_header_action.value
      }
    }
    dynamic "response_header_action" {
      for_each = each.value.actions.response_header_action == null ? [] : ["enabled"]
      content {
        header_action = each.value.actions.response_header_action.header_action
        header_name   = each.value.actions.response_header_action.header_name
        value         = each.value.actions.response_header_action.value
      }
    }
  }

  dynamic "conditions" {
    for_each = each.value.conditions == null ? [] : ["enabled"]
    content {

      dynamic "remote_address_condition" {
        for_each = each.value.conditions.remote_address_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.remote_address_condition.operator
          negate_condition = each.value.conditions.remote_address_condition.negate_condition
          match_values     = each.value.conditions.remote_address_condition.match_values
        }
      }
      dynamic "request_method_condition" {
        for_each = each.value.conditions.request_method_condition == null ? [] : ["enabled"]
        content {
          match_values     = each.value.conditions.request_method_condition.match_values
          operator         = each.value.conditions.request_method_condition.operator
          negate_condition = each.value.conditions.request_method_condition.negate_condition
        }
      }
      dynamic "query_string_condition" {
        for_each = each.value.conditions.query_string_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.query_string_condition.operator
          negate_condition = each.value.conditions.query_string_condition.negate_condition
          match_values     = each.value.conditions.query_string_condition.negate_condition
          transforms       = each.value.conditions.query_string_condition.transforms
        }
      }
      dynamic "post_args_condition" {
        for_each = each.value.conditions.post_args_condition == null ? [] : ["enabled"]
        content {
          post_args_name   = each.value.conditions.post_args_condition.post_args_name
          operator         = each.value.conditions.post_args_condition.operator
          negate_condition = each.value.conditions.post_args_condition.negate_condition
          match_values     = each.value.conditions.post_args_condition.match_values
          transforms       = each.value.conditions.post_args_condition.transforms
        }
      }
      dynamic "request_uri_condition" {
        for_each = each.value.conditions.request_uri_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.request_uri_condition.operator
          negate_condition = each.value.conditions.request_uri_condition.negate_condition
          match_values     = each.value.conditions.request_uri_condition.match_values
          transforms       = each.value.conditions.request_uri_condition.transforms
        }
      }
      dynamic "request_header_condition" {
        for_each = each.value.conditions.request_header_condition == null ? [] : ["enabled"]
        content {
          header_name      = each.value.conditions.request_header_condition.header_name
          operator         = each.value.conditions.request_header_condition.operator
          negate_condition = each.value.conditions.request_header_condition.negate_condition
          match_values     = each.value.conditions.request_header_condition.match_values
          transforms       = each.value.conditions.request_header_condition.transforms
        }
      }
      dynamic "request_body_condition" {
        for_each = each.value.conditions.request_body_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.request_body_condition.operator
          match_values     = each.value.conditions.request_body_condition.match_values
          negate_condition = each.value.conditions.request_body_condition.negate_condition
          transforms       = each.value.conditions.request_body_condition.transforms
        }
      }
      dynamic "request_scheme_condition" {
        for_each = each.value.conditions.request_scheme_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.request_scheme_condition.operator
          negate_condition = each.value.conditions.request_scheme_condition.negate_condition
          match_values     = each.value.conditions.request_scheme_condition.match_values
        }
      }
      dynamic "url_path_condition" {
        for_each = each.value.conditions.url_path_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.url_path_condition.operator
          negate_condition = each.value.conditions.url_path_condition.negate_condition
          match_values     = each.value.conditions.url_path_condition.match_values
          transforms       = each.value.conditions.url_path_condition.transforms
        }
      }
      dynamic "url_file_extension_condition" {
        for_each = each.value.conditions.url_file_extension_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.url_file_extension_condition.operator
          negate_condition = each.value.conditions.url_file_extension_condition.negate_condition
          match_values     = each.value.conditions.url_file_extension_condition.match_values
          transforms       = each.value.conditions.url_file_extension_condition.transforms
        }
      }
      dynamic "url_filename_condition" {
        for_each = each.value.conditions.url_filename_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.url_filename_condition.operator
          match_values     = each.value.conditions.url_filename_condition.match_values
          negate_condition = each.value.conditions.url_filename_condition.negate_condition
          transforms       = each.value.conditions.url_filename_condition.transforms
        }
      }
      dynamic "http_version_condition" {
        for_each = each.value.conditions.http_version_condition == null ? [] : ["enabled"]
        content {
          match_values     = each.value.conditions.http_version_condition.match_values
          operator         = each.value.conditions.http_version_condition.operator
          negate_condition = each.value.conditions.http_version_condition.negate_condition
        }
      }
      dynamic "cookies_condition" {
        for_each = each.value.conditions.cookies_condition == null ? [] : ["enabled"]
        content {
          cookie_name      = each.value.conditions.cookies_condition.cookie_name
          operator         = each.value.conditions.cookies_condition.operator
          negate_condition = each.value.conditions.cookies_condition.negate_condition
          match_values     = each.value.conditions.cookies_condition.match_values
          transforms       = each.value.conditions.cookies_condition.transforms
        }
      }
      dynamic "is_device_condition" {
        for_each = each.value.conditions.is_device_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.is_device_condition.operator
          negate_condition = each.value.conditions.is_device_condition.negate_condition
          match_values     = each.value.conditions.is_device_condition.match_values
        }
      }
      dynamic "socket_address_condition" {
        for_each = each.value.conditions.socket_address_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.socket_address_condition.operator
          negate_condition = each.value.conditions.socket_address_condition.negate_condition
          match_values     = each.value.conditions.socket_address_condition.match_values
        }
      }
      dynamic "client_port_condition" {
        for_each = each.value.conditions.client_port_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.client_port_condition.operator
          negate_condition = each.value.conditions.client_port_condition.negate_condition
          match_values     = each.value.conditions.client_port_condition.match_values
        }
      }
      dynamic "server_port_condition" {
        for_each = each.value.conditions.server_port_condition == null ? [] : ["enabled"]
        content {
          operator         = each.value.conditions.server_port_condition.operator
          match_values     = each.value.conditions.server_port_condition.match_values
          negate_condition = each.value.conditions.server_port_condition.negate_condition
        }
      }
      dynamic "host_name_condition" {
        for_each = each.value.conditions.host_name_condition == null ? [] : ["enabled"]
        content {
          operator     = each.value.conditions.host_name_condition.operator
          match_values = each.value.conditions.host_name_condition.match_values
          transforms   = each.value.conditions.host_name_condition.transforms
        }
      }
      dynamic "ssl_protocol_condition" {
        for_each = each.value.conditions.ssl_protocol_condition == null ? [] : ["enabled"]
        content {
          match_values     = each.value.conditions.ssl_protocol_condition.match_values
          operator         = each.value.conditions.ssl_protocol_condition.operator
          negate_condition = each.value.conditions.ssl_protocol_condition.negate_condition
        }
      }
    }
  }
}
