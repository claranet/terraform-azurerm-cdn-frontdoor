resource "azurerm_cdn_frontdoor_rule_set" "main" {
  for_each = {
    for rule_set in var.rule_sets : rule_set.name => rule_set
  }

  name = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_rule_set[each.key].result)

  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

moved {
  from = azurerm_cdn_frontdoor_rule_set.cdn_frontdoor_rule_set
  to   = azurerm_cdn_frontdoor_rule_set.main
}

resource "azurerm_cdn_frontdoor_rule" "main" {
  for_each = {
    for rule in local.rules_per_rule_set : format("%s.%s", rule.rule_set_name, rule.name) => rule
  }

  name = coalesce(each.value.custom_resource_name, data.azurecaf_name.cdn_frontdoor_rule[each.key].result)

  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.main[each.value.rule_set_name].id

  order              = each.value.order
  behaviour_on_match = each.value.behavior_on_match

  actions {
    dynamic "url_rewrite" {
      for_each = each.value.actions.url_rewrite_actions
      iterator = action
      content {
        source_pattern                  = action.value.source_pattern
        destination_path                = action.value.destination
        preserve_unmatched_path_enabled = action.value.preserve_unmatched_path
      }
    }
    dynamic "url_redirect" {
      for_each = each.value.actions.url_redirect_actions
      iterator = action
      content {
        redirect_type     = action.value.redirect_type
        redirect_protocol = action.value.redirect_protocol
        # AzureRM 5.0 no longer accepts a literal empty string here: to preserve the incoming
        # value the argument has to be omitted, so empty strings are mapped to null.
        destination_host_name = action.value.destination_hostname == "" ? null : action.value.destination_hostname
        destination_path      = action.value.destination_path == "" ? null : action.value.destination_path
        query_string          = action.value.query_string == "" ? null : action.value.query_string
        destination_fragment  = action.value.destination_fragment == "" ? null : action.value.destination_fragment
      }
    }
    dynamic "route_configuration_override" {
      for_each = each.value.actions.route_configuration_override_actions
      iterator = action
      content {
        # The flat action was split into `caching` and `origin_group` sub-blocks by AzureRM 5.0.
        dynamic "caching" {
          for_each = action.value.cache_behavior != null ? ["enabled"] : []
          content {
            behaviour               = action.value.cache_behavior
            duration                = action.value.cache_duration
            query_string_behaviour  = action.value.query_string_caching_behavior
            query_string_parameters = action.value.query_string_parameters
            compression_enabled     = action.value.compression_enabled
          }
        }
        dynamic "origin_group" {
          for_each = (action.value.cdn_frontdoor_origin_group_name != null || action.value.cdn_frontdoor_origin_group_id != null) ? ["enabled"] : []
          content {
            cdn_frontdoor_origin_group_id = action.value.cdn_frontdoor_origin_group_name != null ? azurerm_cdn_frontdoor_origin_group.main[action.value.cdn_frontdoor_origin_group_name].id : action.value.cdn_frontdoor_origin_group_id
            forwarding_protocol           = action.value.forwarding_protocol
          }
        }
      }
    }
    dynamic "modify_request_header" {
      for_each = each.value.actions.request_header_actions
      iterator = action
      content {
        operator     = action.value.header_action
        header_name  = action.value.header_name
        header_value = action.value.value
      }
    }
    dynamic "modify_response_header" {
      for_each = each.value.actions.response_header_actions
      iterator = action
      content {
        operator     = action.value.header_action
        header_name  = action.value.header_name
        header_value = action.value.value
      }
    }
  }

  dynamic "conditions" {
    for_each = each.value.conditions[*]
    content {
      dynamic "remote_address" {
        for_each = each.value.conditions.remote_address_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "request_method" {
        for_each = each.value.conditions.request_method_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "query_string" {
        for_each = each.value.conditions.query_string_conditions
        iterator = condition
        content {
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "post_argument" {
        for_each = each.value.conditions.post_args_conditions
        iterator = condition
        content {
          name       = condition.value.post_args_name
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "request_url" {
        for_each = each.value.conditions.request_uri_conditions
        iterator = condition
        content {
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "request_header" {
        for_each = each.value.conditions.request_header_conditions
        iterator = condition
        content {
          name       = condition.value.header_name
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "request_body" {
        for_each = each.value.conditions.request_body_conditions
        iterator = condition
        content {
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "request_scheme" {
        for_each = each.value.conditions.request_scheme_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "request_path" {
        for_each = each.value.conditions.url_path_conditions
        iterator = condition
        content {
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "request_file_extension" {
        for_each = each.value.conditions.url_file_extension_conditions
        iterator = condition
        content {
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "request_filename" {
        for_each = each.value.conditions.url_filename_conditions
        iterator = condition
        content {
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "http_version" {
        for_each = each.value.conditions.http_version_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "request_cookies" {
        for_each = each.value.conditions.cookies_conditions
        iterator = condition
        content {
          name       = condition.value.cookie_name
          operator   = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "device_type" {
        for_each = each.value.conditions.is_device_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "socket_address" {
        for_each = each.value.conditions.socket_address_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "client_port" {
        for_each = each.value.conditions.client_port_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "server_port" {
        for_each = each.value.conditions.server_port_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
      dynamic "host_name" {
        for_each = each.value.conditions.host_name_conditions
        iterator = condition
        content {
          operator   = condition.value.operator
          values     = condition.value.match_values
          transforms = condition.value.transforms
        }
      }
      dynamic "ssl_protocol" {
        for_each = each.value.conditions.ssl_protocol_conditions
        iterator = condition
        content {
          operator = try(condition.value.negate_condition, false) ? format("Not%s", condition.value.operator) : condition.value.operator
          values   = condition.value.match_values
        }
      }
    }
  }

  depends_on = [
    azurerm_cdn_frontdoor_origin_group.main,
    azurerm_cdn_frontdoor_origin.main,
  ]
}

moved {
  from = azurerm_cdn_frontdoor_rule.cdn_frontdoor_rule
  to   = azurerm_cdn_frontdoor_rule.main
}
