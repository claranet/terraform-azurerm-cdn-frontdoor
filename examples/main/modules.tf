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
