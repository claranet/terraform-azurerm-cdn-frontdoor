# Azure Front Door
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

module "frontdoor_waf" {
  source  = "claranet/front-door/azurerm//modules/waf-policy"
  version = "x.x.x"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name

  managed_rules = [
    {
      type    = "DefaultRuleSet"
      version = "1.0"
      overrides = [{
        rule_group_name = "PHP"
        rules = [{
          action  = "Block"
          enabled = false
          rule_id = 933111
        }]
      }]
    },
    {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    },
  ]

  # Custom error page 
  #custom_block_response_body = filebase64("${path.module}/files/403.html")
}

module "frontdoor_standard" {
  source  = "claranet/cdn-frontdoor/azurerm"
  version = "x.x.x"

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = module.rg.resource_group_name

  # frontdoor_waf_policy_id = module.front_door_waf.waf_policy_id

  origin_groups = {
    contoso = {
      health_probe = {
        interval_in_seconds = 250
        path                = "/"
        protocol            = "Https"
        request_type        = "GET"
      }
      load_balancing = {
        successful_samples_required = 1
      }
    }
  }

  origins = {
    contoso-com = {
      origin_group_short_name        = "contoso"
      certificate_name_check_enabled = false
      host_name                      = "www.contoso.com"
    }
  }

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id
  ]

  extra_tags = {
    foo = "bar"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| azurecaf | ~> 1.1, >= 1.2.19 |
| azurerm | >= 3.25 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| diagnostics | claranet/diagnostic-settings/azurerm | 6.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.frontdoor_endpoint](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.frontdoor_lb](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.frontdoor_origin](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.frontdoor_origin_group](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.frontdoor_probe](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.frontdoor_profile](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.frontdoor_origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.frontdoor_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| default\_tags\_enabled | Option to enable or disable default tags | `bool` | `true` | no |
| endpoint\_enabled | Specifies if this CDN FrontDoor Endpoint is enabled | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Extra tags to add | `map(string)` | `{}` | no |
| frontdoor\_endpoint\_name | Specifies the name of the FrontDoor Endpoint. | `string` | `""` | no |
| frontdoor\_profile\_name | Specifies the name of the FrontDoor Profile. | `string` | `""` | no |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| logs\_retention\_days | Number of days to keep logs on storage account | `number` | `30` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| origin\_groups | Manages CDN FrontDoor Origin Groups | <pre>map(object({<br>    custom_name                                               = optional(string)<br>    session_affinity_enabled                                  = optional(bool, true)<br>    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)<br>    health_probe = optional(object({<br>      interval_in_seconds = number<br>      path                = string<br>      protocol            = string<br>      request_type        = string<br>    }))<br>    load_balancing = object({<br>      additional_latency_in_milliseconds = optional(number, 0)<br>      sample_size                        = optional(number, 16)<br>      successful_samples_required        = optional(number, 3)<br>    })<br>  }))</pre> | `{}` | no |
| origins | Manages CDN FrontDoor Origins | <pre>map(object({<br>    custom_name             = optional(string)<br>    origin_group_short_name = string<br>    enabled                 = optional(bool, true)<br>    #health_probes_enabled          = optional(bool, true)<br>    certificate_name_check_enabled = optional(bool, true)<br><br>    host_name          = string<br>    http_port          = optional(number, 80)<br>    https_port         = optional(number, 443)<br>    origin_host_header = optional(string)<br>    priority           = optional(number, 1)<br>    weight             = optional(number, 1)<br><br>    private_link = optional(object({<br>      request_message        = optional(string)<br>      target_type            = optional(string)<br>      location               = string<br>      private_link_target_id = string<br>    }))<br>  }))</pre> | `{}` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| response\_timeout\_seconds | Specifies the maximum response timeout in seconds. Possible values are between `16` and `240` seconds (inclusive). | `number` | `null` | no |
| sku\_name | Specifies the SKU for this CDN FrontDoor Profile. Possible values include `Standard_AzureFrontDoor` and `Premium_AzureFrontDoor`. | `string` | `"Standard_AzureFrontDoor"` | no |
| stack | Project stack name | `string` | n/a | yes |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
## Related documentation

Azure Front Door: [docs.microsoft.com/en-us/rest/api/frontdoor/](https://docs.microsoft.com/en-us/rest/api/frontdoor/)
