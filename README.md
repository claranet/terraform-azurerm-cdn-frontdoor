# Azure CDN FrontDoor
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/cdn-frontdoor/azurerm/)

This Terraform module is designed to create an [Azure CDN FrontDoor (Standard/Premium)](https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison) resource.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

module "cdn_frontdoor" {

  source  = "claranet/cdn-frontdoor/azurerm"
  version = "x.x.x"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name

  sku_name = "Premium_AzureFrontDoor"

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id
  ]

  endpoints = [
    {
      name = "web"
    },
    {
      name    = "azure"
      enabled = false
    }
  ]

  origin_groups = [
    {
      name = "contoso"
      health_probe = {
        interval_in_seconds = 250
        path                = "/"
        protocol            = "Https"
        request_type        = "GET"
      }
      load_balancing = {
        successful_samples_required = 1
      }
    },
    {
      name = "contoso2"
      health_probe = {
        interval_in_seconds = 250
        path                = "/"
        protocol            = "Https"
        request_type        = "GET"
      }
    }
  ]

  origins = [
    {
      name                           = "web"
      origin_group_name              = "contoso"
      certificate_name_check_enabled = false
      host_name                      = "www.contoso.com"
    },
    {
      name                           = "azure"
      origin_group_name              = "contoso2"
      certificate_name_check_enabled = false
      host_name                      = "azure.contoso.com"
    }
  ]

  custom_domains = [
    {
      name      = "www"
      host_name = "www.contoso.com"
    }
  ]

  routes = [
    {
      name                 = "route66"
      endpoint_name        = "web"
      origin_group_name    = "contoso"
      origins_names        = ["web", "azure"]
      forwarding_protocol  = "HttpsOnly"
      patterns_to_match    = ["/*"]
      supported_protocols  = ["Http", "Https"]
      custom_domains_names = ["www"]
      rule_sets_names      = ["my_rule_set", "my_rule_set2"]
    },
    {
      name                = "route2"
      endpoint_name       = "azure"
      origin_group_name   = "contoso2"
      origins_names       = ["web"]
      forwarding_protocol = "HttpsOnly"
      patterns_to_match   = ["/contoso"]
      supported_protocols = ["Http", "Https"]
      rule_sets_names     = ["my_rule_set", "my_rule_set2"]
    }
  ]

  rule_sets = [
    {
      name                 = "my_rule_set"
      custom_resource_name = "custom_rule"
      rules = [
        {
          name                 = "redirect"
          custom_resource_name = "myrulename"
          order                = 1
          actions = {
            url_rewrite_action = {
              source_pattern = "/"
              destination    = "/contoso"
            }
          }
          conditions = {
            is_device_condition = {
              operator     = "Equal"
              match_values = ["Desktop"]
            }
          }
        }
      ]
    },
    {
      name                 = "my_rule_set2"
      custom_resource_name = "custom_rule2"
    }
  ]

  firewall_policies = [
    {
      name                              = "test"
      enabled                           = true
      mode                              = "Prevention"
      redirect_url                      = "https://www.contoso.com"
      custom_block_response_status_code = 403
      custom_block_response_body        = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="

      custom_rules = [
        {
          name                           = "Rule1"
          enabled                        = true
          priority                       = 1
          rate_limit_duration_in_minutes = 1
          rate_limit_threshold           = 10
          type                           = "MatchRule"
          action                         = "Block"

          match_conditions = [
            {
              match_variable     = "RemoteAddr"
              operator           = "IPMatch"
              negation_condition = false
              match_values       = ["10.0.1.0/24", "10.0.0.0/24"]
            }
          ]
        },
        {
          name                           = "Rule2"
          enabled                        = true
          priority                       = 2
          rate_limit_duration_in_minutes = 1
          rate_limit_threshold           = 10
          type                           = "MatchRule"
          action                         = "Block"

          match_conditions = [
            {
              match_variable     = "RemoteAddr"
              operator           = "IPMatch"
              negation_condition = false
              match_values       = ["192.168.1.0/24"]
            },
            {
              match_variable     = "RequestHeader"
              selector           = "UserAgent"
              operator           = "Contains"
              negation_condition = false
              match_values       = ["windows"]
              transforms         = ["Lowercase", "Trim"]
            }
          ]
        }
      ]

      managed_rules = [
        {
          type    = "DefaultRuleSet"
          version = "1.0"
          action  = "Log"

          exclusions = [
            {
              match_variable = "QueryStringArgNames"
              operator       = "Equals"
              selector       = "not_suspicious"
            }
          ]

          overrides = [
            {
              rule_group_name = "PHP"

              rules = [
                {
                  rule_id = "933100"
                  enabled = false
                  action  = "Block"
                }
              ]
            },
            {
              rule_group_name = "SQLI"

              exclusions = [{
                match_variable = "QueryStringArgNames"
                operator       = "Equals"
                selector       = "really_not_suspicious"
                }
              ]

              rules = [{
                rule_id = "942200"
                action  = "Block"

                exclusions = [
                  {
                    match_variable = "QueryStringArgNames"
                    operator       = "Equals"
                    selector       = "innocent"
                  }
                ]
                }
              ]
            }
          ]
        },
        {
          type    = "Microsoft_BotManagerRuleSet"
          version = "1.0"
          action  = "Log"
        }
      ]

    }
  ]

  security_policies = [
    {
      name                 = "MySecurityPolicy"
      custom_resource_name = "MyBetterNamedSecurityPolicy"
      firewall_policy_name = "test"
      patterns_to_match    = ["/*"]
      custom_domain_names  = ["www"]
      endpoint_names       = ["web", "azure"]
    }
  ]

  extra_tags = {
    foo = "bar"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| azurecaf | ~> 1.2, >= 1.2.22 |
| azurerm | ~> 3.33 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostics | claranet/diagnostic-settings/azurerm | 6.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_custom_domain.cdn_frontdoor_custom_domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_endpoint.cdn_frontdoor_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_firewall_policy.cdn_frontdoor_firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_firewall_policy) | resource |
| [azurerm_cdn_frontdoor_origin.cdn_frontdoor_origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.cdn_frontdoor_origin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.cdn_frontdoor_route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_rule.cdn_frontdoor_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule_set.cdn_frontdoor_rule_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_security_policy.cdn_frontdoor_security_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) | resource |
| [azurecaf_name.cdn_frontdoor_custom_domain](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_endpoint](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_firewall_policy](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_origin](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_origin_group](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_profile](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_route](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_rule](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_rule_set](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_security_policy](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/data-sources/name) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cdn\_frontdoor\_profile\_name | Specifies the name of the FrontDoor Profile. | `string` | `""` | no |
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| custom\_domains | CDN FrontDoor Custom Domains configurations. | <pre>list(object({<br>    name                 = string<br>    custom_resource_name = optional(string)<br>    host_name            = string<br>    dns_zone_id          = optional(string)<br>    tls = optional(object({<br>      certificate_type        = optional(string, "ManagedCertificate")<br>      minimum_tls_version     = optional(string, "TLS12")<br>      cdn_frontdoor_secret_id = optional(string)<br>    }), {})<br>  }))</pre> | `[]` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| endpoints | CDN FrontDoor Endpoints configurations. | <pre>list(object({<br>    name                 = string<br>    prefix               = optional(string)<br>    custom_resource_name = optional(string)<br>    enabled              = optional(bool, true)<br>  }))</pre> | `[]` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Extra tags to add. | `map(string)` | `{}` | no |
| firewall\_policies | CDN Frontdoor Firewall Policies configurations. | <pre>list(object({<br>    name                              = string<br>    custom_resource_name              = optional(string)<br>    enabled                           = optional(bool, true)<br>    mode                              = optional(string, "Prevention")<br>    redirect_url                      = optional(string)<br>    custom_block_response_status_code = optional(number)<br>    custom_block_response_body        = optional(string)<br>    custom_rules = optional(list(object({<br>      name                           = string<br>      action                         = string<br>      enabled                        = optional(bool, true)<br>      priority                       = number<br>      type                           = string<br>      rate_limit_duration_in_minutes = optional(number, 1)<br>      rate_limit_threshold           = optional(number, 10)<br>      match_conditions = list(object({<br>        match_variable   = string<br>        match_values     = list(string)<br>        operator         = string<br>        selector         = optional(string)<br>        negate_condition = optional(bool)<br>        transforms       = optional(list(string), [])<br>      }))<br>    })), [])<br>    managed_rules = optional(list(object({<br>      type    = string<br>      version = optional(string, "1.0")<br>      action  = string<br>      exclusions = optional(list(object({<br>        match_variable = string<br>        operator       = string<br>        selector       = string<br>      })), [])<br>      overrides = optional(list(object({<br>        rule_group_name = string<br>        exclusions = optional(list(object({<br>          match_variable = string<br>          operator       = string<br>          selector       = string<br>        })), [])<br>        rules = optional(list(object({<br>          rule_id = string<br>          action  = string<br>          enabled = optional(bool, true)<br>          exclusions = optional(list(object({<br>            match_variable = string<br>            operator       = string<br>            selector       = string<br>        })), []) })), [])<br>      })), [])<br>    })), [])<br>  }))</pre> | `[]` | no |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| logs\_retention\_days | Number of days to keep logs on storage account | `number` | `30` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| origin\_groups | CDN FrontDoor Origin Groups configurations. | <pre>list(object({<br>    name                                                      = string<br>    custom_resource_name                                      = optional(string)<br>    session_affinity_enabled                                  = optional(bool, true)<br>    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)<br>    health_probe = optional(object({<br>      interval_in_seconds = number<br>      path                = string<br>      protocol            = string<br>      request_type        = string<br>    }))<br>    load_balancing = optional(object({<br>      additional_latency_in_milliseconds = optional(number, 50)<br>      sample_size                        = optional(number, 4)<br>      successful_samples_required        = optional(number, 3)<br>    }), {})<br>  }))</pre> | `[]` | no |
| origins | CDN FrontDoor Origins configurations. | <pre>list(object({<br>    name                           = string<br>    custom_resource_name           = optional(string)<br>    origin_group_name              = string<br>    enabled                        = optional(bool, true)<br>    certificate_name_check_enabled = optional(bool, true)<br><br>    host_name          = string<br>    http_port          = optional(number, 80)<br>    https_port         = optional(number, 443)<br>    origin_host_header = optional(string)<br>    priority           = optional(number, 1)<br>    weight             = optional(number, 1)<br><br>    private_link = optional(object({<br>      request_message        = optional(string)<br>      target_type            = optional(string)<br>      location               = string<br>      private_link_target_id = string<br>    }))<br>  }))</pre> | `[]` | no |
| resource\_group\_name | Resource group name. | `string` | n/a | yes |
| response\_timeout\_seconds | Specifies the maximum response timeout in seconds. Possible values are between `16` and `240` seconds (inclusive). | `number` | `120` | no |
| routes | CDN FrontDoor Routes configurations. | <pre>list(object({<br>    name                 = string<br>    custom_resource_name = optional(string)<br>    enabled              = optional(bool, true)<br><br>    endpoint_name     = string<br>    origin_group_name = string<br>    origins_names     = list(string)<br><br>    forwarding_protocol = optional(string, "HttpsOnly")<br>    patterns_to_match   = optional(list(string), ["/*"])<br>    supported_protocols = optional(list(string), ["Http", "Https"])<br>    cache = optional(object({<br>      query_string_caching_behavior = optional(string, "IgnoreQueryString")<br>      query_strings                 = optional(list(string))<br>      compression_enabled           = optional(bool, false)<br>      content_types_to_compress     = optional(list(string))<br>    }))<br><br>    custom_domains_names = optional(list(string), [])<br>    origin_path          = optional(string, "/")<br>    rule_sets_names      = optional(list(string), [])<br><br>    https_redirect_enabled = optional(bool, true)<br>    link_to_default_domain = optional(bool, true)<br>  }))</pre> | `[]` | no |
| rule\_sets | CDN FrontDoor Rule Sets and associated Rules configurations. | <pre>list(object({<br>    name                 = string<br>    custom_resource_name = optional(string)<br>    rules = optional(list(object({<br>      name                 = string<br>      custom_resource_name = optional(string)<br>      order                = number<br>      behavior_on_match    = optional(string, "Continue")<br><br>      actions = object({<br>        url_rewrite_action = optional(object({<br>          source_pattern          = optional(string)<br>          destination             = optional(string)<br>          preserve_unmatched_path = optional(bool, false)<br>        }))<br>        url_redirect_action = optional(object({<br>          redirect_type        = string<br>          destination_hostname = string<br>          redirect_protocol    = optional(string, "MatchRequest")<br>          destination_path     = optional(string, "")<br>          query_string         = optional(string, "")<br>          destination_fragment = optional(string, "")<br>        }))<br>        route_configuration_override_action = optional(object({<br>          cache_duration                = optional(string, "1.12:00:00")<br>          cdn_frontdoor_origin_group_id = optional(string)<br>          forwarding_protocol           = optional(string, "MatchRequest")<br>          query_string_caching_behavior = optional(string, "IgnoreQueryString")<br>          query_string_parameters       = optional(list(string))<br>          compression_enabled           = optional(bool, false)<br>          cache_behavior                = optional(string, "HonorOrigin")<br>        }))<br>        request_header_action = optional(object({<br>          header_action = string<br>          header_name   = string<br>          value         = optional(string)<br>        }))<br>        response_header_action = optional(object({<br>          header_action = string<br>          header_name   = string<br>          value         = optional(string)<br>        }))<br>      })<br>      conditions = optional(object({<br>        remote_address_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>        }))<br>        request_method_condition = optional(object({<br>          match_values     = list(string)<br>          operator         = optional(string, "Equal")<br>          negate_condition = optional(bool, false)<br>        }))<br>        query_string_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        post_args_condition = optional(object({<br>          post_args_name   = string<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        request_uri_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        request_header_condition = optional(object({<br>          header_name      = string<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        request_body_condition = optional(object({<br>          operator         = string<br>          match_values     = list(string)<br>          negate_condition = optional(bool, false)<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        request_scheme_condition = optional(object({<br>          operator         = optional(string, "Equal")<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(string, "HTTP")<br>        }))<br>        url_path_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        url_file_extension_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = list(string)<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        url_filename_condition = optional(object({<br>          operator         = string<br>          match_values     = list(string)<br>          negate_condition = optional(bool, false)<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        http_version_condition = optional(object({<br>          match_values     = list(string)<br>          operator         = optional(string, "Equal")<br>          negate_condition = optional(bool, false)<br>        }))<br>        cookies_condition = optional(object({<br>          cookie_name      = string<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>          transforms       = optional(list(string), ["Lowercase"])<br>        }))<br>        is_device_condition = optional(object({<br>          operator         = optional(string, "Equal")<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string), ["Mobile"])<br>        }))<br>        socket_address_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>        }))<br>        client_port_condition = optional(object({<br>          operator         = string<br>          negate_condition = optional(bool, false)<br>          match_values     = optional(list(string))<br>        }))<br>        server_port_condition = optional(object({<br>          operator         = string<br>          match_values     = list(string)<br>          negate_condition = optional(bool, false)<br>        }))<br>        host_name_condition = optional(object({<br>          operator     = string<br>          match_values = list(string)<br>          transforms   = optional(list(string), ["Lowercase"])<br>        }))<br>        ssl_protocol_condition = optional(object({<br>          match_values     = list(string)<br>          operator         = optional(string, "Equal")<br>          negate_condition = optional(bool, false)<br>        }))<br>      }))<br>    })), [])<br>  }))</pre> | `[]` | no |
| security\_policies | CDN FrontDoor Security policies configurations. | <pre>list(object({<br>    name                 = string<br>    custom_resource_name = optional(string)<br>    firewall_policy_name = string<br>    patterns_to_match    = optional(list(string), ["/*"])<br>    custom_domain_names  = optional(list(string), [])<br>    endpoint_names       = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| sku\_name | Specifies the SKU for this CDN FrontDoor Profile. Possible values include `Standard_AzureFrontDoor` and `Premium_AzureFrontDoor`. | `string` | `"Standard_AzureFrontDoor"` | no |
| stack | Project stack name. | `string` | n/a | yes |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| custom\_domains | CDN FrontDoor custom domains outputs. |
| endpoints | CDN FrontDoor endpoints outputs. |
| firewall\_policies | CDN FrontDoor firewall policies outputs. |
| origin\_groups | CDN FrontDoor origin groups outputs. |
| origins | CDN FrontDoor origins outputs. |
| profile\_id | The ID of the CDN FrontDoor Profile. |
| profile\_name | The name of the CDN FrontDoor Profile. |
| rule\_sets | CDN FrontDoor rule sets outputs. |
| rules | CDN FrontDoor rules outputs. |
| security\_policies | CDN FrontDoor security policies outputs. |
<!-- END_TF_DOCS -->
## Related documentation

Azure Front Door REST API: [docs.microsoft.com/en-us/rest/api/frontdoor/](https://docs.microsoft.com/en-us/rest/api/frontdoor/)
