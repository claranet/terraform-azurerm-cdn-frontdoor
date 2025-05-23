# Azure CDN FrontDoor
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/claranet/cdn-frontdoor/azurerm/)

This Terraform module is designed to create an [Azure CDN FrontDoor (Standard/Premium)](https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison) resource.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | OpenTofu version | AzureRM version |
| -------------- | ----------------- | ---------------- | --------------- |
| >= 8.x.x       | **Unverified**    | 1.8.x            | >= 4.0          |
| >= 7.x.x       | 1.3.x             |                  | >= 3.0          |
| >= 6.x.x       | 1.x               |                  | >= 3.0          |
| >= 5.x.x       | 0.15.x            |                  | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   |                  | >= 2.0          |
| >= 3.x.x       | 0.12.x            |                  | >= 2.0          |
| >= 2.x.x       | 0.12.x            |                  | < 2.0           |
| <  2.x.x       | 0.11.x            |                  | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

⚠️ Since modules version v8.0.0, we do not maintain/check anymore the compatibility with
[Hashicorp Terraform](https://github.com/hashicorp/terraform/). Instead, we recommend to use [OpenTofu](https://github.com/opentofu/opentofu/).

```hcl
# NOTE: In order for the certificate to be used by Azure FrontDoor, it must be PKCS#12 PFX 3DES.
# The PFX must only contain the leaf and any intermediates, but it must not contain any Root CAs
# already trusted by Azure. openssl v3 requires -legacy flag for 3DES compatibility.
# Generate the CSR, get it signed by the CA, then create the PFX.
#
# openssl pkcs12 -export -out cert.pfx -inkey leaf.key -in leaf.pem -certfile intermediate.pem -legacy
#
resource "azurerm_key_vault_certificate" "cert" {
  name         = "custom-contoso-com"
  key_vault_id = var.key_vault_id

  certificate {
    contents = "abcd" # filebase64("./cert.pfx")
    password = ""
  }

  # The following is required for PFX imports, but not PEM.
  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }
    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }

}

module "cdn_frontdoor" {
  source  = "claranet/cdn-frontdoor/azurerm"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.name

  sku_name = "Premium_AzureFrontDoor"

  logs_destinations_ids = [
    module.logs.id,
    module.logs.storage_account_id,
  ]

  endpoints = [
    {
      name = "web"
    },
    {
      name    = "azure"
      enabled = false
    },
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
    },
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
    },
  ]

  custom_domains = [
    {
      name      = "www"
      host_name = "www.contoso.com"
    },
    {
      name      = "custom-contoso-com"
      host_name = "custom.contoso.com"
      tls = {
        certificate_type         = "CustomerCertificate"
        key_vault_certificate_id = azurerm_key_vault_certificate.cert.id
      }
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
    },
  ]

  rule_sets = [
    {
      name                 = "my_rule_set"
      custom_resource_name = "custom_rule"

      rules = [{
        name                 = "redirect"
        custom_resource_name = "myrulename"
        order                = 1
        actions = {
          response_header_actions = [
            {
              header_action = "Overwrite"
              header_name   = "Access-Control-Allow-Origin"
              value         = "https://www.foo.bar.fr"
            },
            {
              header_action = "Overwrite"
              header_name   = "Access-Control-Allow-Credentials"
              value         = "true"
            },
            {
              header_action = "Overwrite"
              header_name   = "Access-Control-Allow-Headers"
              value         = "Authorization, Content-Type, ocp-apim-subscription-key"
            },
            {
              header_action = "Overwrite"
              header_name   = "Access-Control-Allow-Methods"
              value         = "POST,PUT,GET,DELETE,OPTIONS"
            },
          ]
          url_rewrite_actions = [{
            source_pattern = "/"
            destination    = "/contoso"
          }]
        }
        conditions = {
          is_device_conditions = [{
            operator     = "Equal"
            match_values = ["Desktop"]
          }]
        }
      }]
    },
    {
      name                 = "my_rule_set2"
      custom_resource_name = "custom_rule2"
    },
  ]

  firewall_policies = [{
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
        match_conditions = [{
          match_variable     = "RemoteAddr"
          operator           = "IPMatch"
          negation_condition = false
          match_values       = ["10.0.1.0/24", "10.0.0.0/24"]
        }]
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
          },
        ]
      },
    ]

    managed_rules = [
      {
        type    = "DefaultRuleSet"
        version = "1.0"
        action  = "Log"
        exclusions = [{
          match_variable = "QueryStringArgNames"
          operator       = "Equals"
          selector       = "not_suspicious"
        }]
        overrides = [
          {
            rule_group_name = "PHP"
            rules = [{
              rule_id = "933100"
              enabled = false
              action  = "Block"
            }]
          },
          {
            rule_group_name = "SQLI"
            exclusions = [{
              match_variable = "QueryStringArgNames"
              operator       = "Equals"
              selector       = "really_not_suspicious"
            }]
            rules = [{
              rule_id = "942200"
              action  = "Block"
              exclusions = [{
                match_variable = "QueryStringArgNames"
                operator       = "Equals"
                selector       = "innocent"
              }]
            }]
          },
        ]
      },
      {
        type    = "Microsoft_BotManagerRuleSet"
        version = "1.0"
        action  = "Log"
      },
    ]
  }]

  security_policies = [{
    name                 = "MySecurityPolicy"
    custom_resource_name = "MyBetterNamedSecurityPolicy"
    firewall_policy_name = "test"
    patterns_to_match    = ["/*"]
    custom_domain_names  = ["www"]
    endpoint_names       = ["web", "azure"]
  }]

  extra_tags = {
    foo = "bar"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| azurecaf | ~> 1.2.28 |
| azurerm | ~> 4.15 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostics | claranet/diagnostic-settings/azurerm | ~> 8.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_custom_domain.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_firewall_policy) | resource |
| [azurerm_cdn_frontdoor_origin.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule_set.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_secret.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_secret) | resource |
| [azurerm_cdn_frontdoor_security_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) | resource |
| [azurecaf_name.cdn_frontdoor_custom_domain](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_endpoint](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_firewall_policy](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_origin](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_origin_group](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_profile](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_route](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_rule](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_rule_set](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |
| [azurecaf_name.cdn_frontdoor_security_policy](https://registry.terraform.io/providers/claranet/azurecaf/latest/docs/data-sources/name) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| custom\_domains | Azure CDN FrontDoor custom domains configurations. | <pre>list(object({<br/>    name                 = string<br/>    custom_resource_name = optional(string)<br/>    host_name            = string<br/>    dns_zone_id          = optional(string)<br/>    tls = optional(object({<br/>      certificate_type         = optional(string, "ManagedCertificate")<br/>      minimum_tls_version      = optional(string, "TLS12")<br/>      cdn_frontdoor_secret_id  = optional(string)<br/>      key_vault_certificate_id = optional(string)<br/>    }), {})<br/>  }))</pre> | `[]` | no |
| custom\_name | Specifies the name of the FrontDoor Profile. | `string` | `""` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| diagnostic\_settings\_custom\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| endpoints | Azure CDN FrontDoor endpoints configurations. | <pre>list(object({<br/>    name                 = string<br/>    prefix               = optional(string)<br/>    custom_resource_name = optional(string)<br/>    enabled              = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Extra tags to add. | `map(string)` | `{}` | no |
| firewall\_policies | Azure CDN Frontdoor firewall policies configurations. | <pre>list(object({<br/>    name                              = string<br/>    custom_resource_name              = optional(string)<br/>    enabled                           = optional(bool, true)<br/>    mode                              = optional(string, "Prevention")<br/>    redirect_url                      = optional(string)<br/>    custom_block_response_status_code = optional(number)<br/>    custom_block_response_body        = optional(string)<br/>    custom_rules = optional(list(object({<br/>      name                           = string<br/>      action                         = string<br/>      enabled                        = optional(bool, true)<br/>      priority                       = number<br/>      type                           = string<br/>      rate_limit_duration_in_minutes = optional(number, 1)<br/>      rate_limit_threshold           = optional(number, 10)<br/>      match_conditions = list(object({<br/>        match_variable   = string<br/>        match_values     = list(string)<br/>        operator         = string<br/>        selector         = optional(string)<br/>        negate_condition = optional(bool)<br/>        transforms       = optional(list(string), [])<br/>      }))<br/>    })), [])<br/>    managed_rules = optional(list(object({<br/>      type    = string<br/>      version = optional(string, "1.0")<br/>      action  = string<br/>      exclusions = optional(list(object({<br/>        match_variable = string<br/>        operator       = string<br/>        selector       = string<br/>      })), [])<br/>      overrides = optional(list(object({<br/>        rule_group_name = string<br/>        exclusions = optional(list(object({<br/>          match_variable = string<br/>          operator       = string<br/>          selector       = string<br/>        })), [])<br/>        rules = optional(list(object({<br/>          rule_id = string<br/>          action  = string<br/>          enabled = optional(bool, true)<br/>          exclusions = optional(list(object({<br/>            match_variable = string<br/>            operator       = string<br/>            selector       = string<br/>        })), []) })), [])<br/>      })), [])<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| identity | Managed identity configuration. SystemAssigned or UserAssigned or Both. | <pre>object({<br/>    type         = optional(string, "SystemAssigned")<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `{}` | no |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br/>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br/>If you want to use Azure EventHub as a destination, you must provide a formatted string containing both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| origin\_groups | Azure CDN FrontDoor origin groups configurations. | <pre>list(object({<br/>    name                                                      = string<br/>    custom_resource_name                                      = optional(string)<br/>    session_affinity_enabled                                  = optional(bool, true)<br/>    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)<br/>    health_probe = optional(object({<br/>      interval_in_seconds = number<br/>      path                = string<br/>      protocol            = string<br/>      request_type        = string<br/>    }))<br/>    load_balancing = optional(object({<br/>      additional_latency_in_milliseconds = optional(number, 50)<br/>      sample_size                        = optional(number, 4)<br/>      successful_samples_required        = optional(number, 3)<br/>    }), {})<br/>  }))</pre> | `[]` | no |
| origins | Azure CDN FrontDoor origins configurations. | <pre>list(object({<br/>    name                           = string<br/>    custom_resource_name           = optional(string)<br/>    origin_group_name              = string<br/>    enabled                        = optional(bool, true)<br/>    certificate_name_check_enabled = optional(bool, true)<br/><br/>    host_name          = string<br/>    http_port          = optional(number, 80)<br/>    https_port         = optional(number, 443)<br/>    origin_host_header = optional(string)<br/>    priority           = optional(number, 1)<br/>    weight             = optional(number, 1)<br/><br/>    private_link = optional(object({<br/>      request_message        = optional(string)<br/>      target_type            = optional(string)<br/>      location               = string<br/>      private_link_target_id = string<br/>    }))<br/>  }))</pre> | `[]` | no |
| resource\_group\_name | Resource group name. | `string` | n/a | yes |
| response\_timeout\_seconds | Specifies the maximum response timeout in seconds. Possible values are between `16` and `240` seconds (inclusive). | `number` | `120` | no |
| routes | Azure CDN FrontDoor routes configurations. | <pre>list(object({<br/>    name                 = string<br/>    custom_resource_name = optional(string)<br/>    enabled              = optional(bool, true)<br/><br/>    endpoint_name     = string<br/>    origin_group_name = string<br/>    origins_names     = list(string)<br/><br/>    forwarding_protocol = optional(string, "HttpsOnly")<br/>    patterns_to_match   = optional(list(string), ["/*"])<br/>    supported_protocols = optional(list(string), ["Http", "Https"])<br/>    cache = optional(object({<br/>      query_string_caching_behavior = optional(string, "IgnoreQueryString")<br/>      query_strings                 = optional(list(string))<br/>      compression_enabled           = optional(bool, false)<br/>      content_types_to_compress     = optional(list(string))<br/>    }))<br/><br/>    custom_domains_names = optional(list(string), [])<br/>    origin_path          = optional(string, "/")<br/>    rule_sets_names      = optional(list(string), [])<br/><br/>    https_redirect_enabled = optional(bool, true)<br/>    link_to_default_domain = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| rule\_sets | Azure CDN FrontDoor rule sets and associated rules configurations. | <pre>list(object({<br/>    name                 = string<br/>    custom_resource_name = optional(string)<br/>    rules = optional(list(object({<br/>      name                 = string<br/>      custom_resource_name = optional(string)<br/>      order                = number<br/>      behavior_on_match    = optional(string, "Continue")<br/><br/>      actions = object({<br/>        url_rewrite_actions = optional(list(object({<br/>          source_pattern          = optional(string)<br/>          destination             = optional(string)<br/>          preserve_unmatched_path = optional(bool, false)<br/>        })), [])<br/>        url_redirect_actions = optional(list(object({<br/>          redirect_type        = string<br/>          destination_hostname = string<br/>          redirect_protocol    = optional(string, "MatchRequest")<br/>          destination_path     = optional(string, "")<br/>          query_string         = optional(string, "")<br/>          destination_fragment = optional(string, "")<br/>        })), [])<br/>        route_configuration_override_actions = optional(list(object({<br/>          cache_duration                = optional(string)<br/>          cdn_frontdoor_origin_group_id = optional(string)<br/>          forwarding_protocol           = optional(string, "MatchRequest")<br/>          query_string_caching_behavior = optional(string, "IgnoreQueryString")<br/>          query_string_parameters       = optional(list(string))<br/>          compression_enabled           = optional(bool, false)<br/>          cache_behavior                = optional(string, "HonorOrigin")<br/>        })), [])<br/>        request_header_actions = optional(list(object({<br/>          header_action = string<br/>          header_name   = string<br/>          value         = optional(string)<br/>        })), [])<br/>        response_header_actions = optional(list(object({<br/>          header_action = string<br/>          header_name   = string<br/>          value         = optional(string)<br/>        })), [])<br/>      })<br/><br/>      conditions = optional(object({<br/>        remote_address_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>        })), [])<br/>        request_method_conditions = optional(list(object({<br/>          match_values     = list(string)<br/>          operator         = optional(string, "Equal")<br/>          negate_condition = optional(bool, false)<br/>        })), [])<br/>        query_string_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        post_args_conditions = optional(list(object({<br/>          post_args_name   = string<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        request_uri_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        request_header_conditions = optional(list(object({<br/>          header_name      = string<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        request_body_conditions = optional(list(object({<br/>          operator         = string<br/>          match_values     = list(string)<br/>          negate_condition = optional(bool, false)<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        request_scheme_conditions = optional(list(object({<br/>          operator         = optional(string, "Equal")<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(string, "HTTP")<br/>        })), [])<br/>        url_path_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        url_file_extension_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = list(string)<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        url_filename_conditions = optional(list(object({<br/>          operator         = string<br/>          match_values     = list(string)<br/>          negate_condition = optional(bool, false)<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        http_version_conditions = optional(list(object({<br/>          match_values     = list(string)<br/>          operator         = optional(string, "Equal")<br/>          negate_condition = optional(bool, false)<br/>        })), [])<br/>        cookies_conditions = optional(list(object({<br/>          cookie_name      = string<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>          transforms       = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        is_device_conditions = optional(list(object({<br/>          operator         = optional(string, "Equal")<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string), ["Mobile"])<br/>        })), [])<br/>        socket_address_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>        })), [])<br/>        client_port_conditions = optional(list(object({<br/>          operator         = string<br/>          negate_condition = optional(bool, false)<br/>          match_values     = optional(list(string))<br/>        })), [])<br/>        server_port_conditions = optional(list(object({<br/>          operator         = string<br/>          match_values     = list(string)<br/>          negate_condition = optional(bool, false)<br/>        })), [])<br/>        host_name_conditions = optional(list(object({<br/>          operator     = string<br/>          match_values = optional(list(string))<br/>          transforms   = optional(list(string), ["Lowercase"])<br/>        })), [])<br/>        ssl_protocol_conditions = optional(list(object({<br/>          match_values     = list(string)<br/>          operator         = optional(string, "Equal")<br/>          negate_condition = optional(bool, false)<br/>        })), [])<br/>      }), null)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| security\_policies | Azure CDN FrontDoor security policies configurations. | <pre>list(object({<br/>    name                 = string<br/>    custom_resource_name = optional(string)<br/>    firewall_policy_name = string<br/>    patterns_to_match    = optional(list(string), ["/*"])<br/>    custom_domain_names  = optional(list(string), [])<br/>    endpoint_names       = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| sku\_name | Specifies the SKU for this Azure CDN FrontDoor profile. Possible values include `Standard_AzureFrontDoor` and `Premium_AzureFrontDoor`. | `string` | `"Standard_AzureFrontDoor"` | no |
| stack | Project stack name. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the CDN FrontDoor Profile. |
| identity\_principal\_id | Azure CDN FrontDoor system identity principal ID. |
| module\_diagnostics | Diagnostics Settings module output. |
| name | The name of the CDN FrontDoor Profile. |
| resource | Azure CDN FrontDoor Profile output object. |
| resource\_custom\_domain | Azure CDN FrontDoor custom domain resource output. |
| resource\_endpoint | Azure CDN FrontDoor endpoints resource output. |
| resource\_firewall\_policy | Azure CDN FrontDoor firewall policy resource output. |
| resource\_origin | Azure CDN FrontDoor origin resource output. |
| resource\_origin\_group | Azure CDN FrontDoor origin group resource output. |
| resource\_route | Azure CDN FrontDoor route resource output. |
| resource\_rule | Azure CDN FrontDoor rule resource output. |
| resource\_rule\_set | Azure CDN FrontDoor rule set resource output. |
| resource\_secret | Azure CDN FrontDoor secret resource output. |
| resource\_security\_policy | Azure CDN FrontDoor security policy resource output. |
<!-- END_TF_DOCS -->
## Related documentation

Azure Front Door REST API: [docs.microsoft.com/en-us/rest/api/frontdoor/](https://docs.microsoft.com/en-us/rest/api/frontdoor/)
