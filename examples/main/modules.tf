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

  frontdoor_waf_policy_id = module.front_door_waf.waf_policy_id

  default_frontend_endpoint_enabled = false
  default_routing_rule_enabled      = false

  frontend_endpoints = [
    {
      name                                    = "custom-fo"
      host_name                               = "custom-fo.example.com"
      web_application_firewall_policy_link_id = module.front_door_waf.waf_policy_id
      custom_https_configuration = {
        certificate_source = "FrontDoor"
      }
    },
    # {
    #   name                                    = "custom-bo"
    #   host_name                               = "custom-bo.example.com"
    #   web_application_firewall_policy_link_id = module.front_door_waf.waf_policy_id
    #   custom_https_configuration = {
    #     certificate_source                         = "AzureKeyVault"
    #     azure_key_vault_certificate_vault_id       = "<key_vault_id>"
    #     azure_key_vault_certificate_secret_name    = "<key_vault_secret_name>"
    #     azure_key_vault_certificate_secret_version = "<secret_version>" # optional, use "latest" if not defined
    #   }
    # },
  ]

  backend_pools = [{
    name = "frontdoor-backend-pool-1",
    backends = [{
      host_header = "custom-fo.example.com"
      address     = "1.2.3.4"
    }]
  }]

  routing_rules = [
    {
      name               = "default"
      frontend_endpoints = ["custom-fo"]
      accepted_protocols = ["Http", "Https"]
      patterns_to_match  = ["/*"]
      forwarding_configurations = [
        {
          backend_pool_name                     = "frontdoor-backend-pool-1"
          cache_enabled                         = false
          cache_use_dynamic_compression         = false
          cache_query_parameter_strip_directive = "StripAll"
          forwarding_protocol                   = "MatchRequest"
        }
      ]
    },
    {
      name               = "deny-install"
      frontend_endpoints = ["custom-fo"]
      accepted_protocols = ["Http", "Https"]
      patterns_to_match  = ["/core/install.php"]

      redirect_configurations = [{
        custom_path       = "/"
        redirect_protocol = "MatchRequest"
        redirect_type     = "Found"
      }]
    },
  ]

  logs_destinations_ids = [
    module.logs.log_analytics_workspace_id,
    module.logs.logs_storage_account_id
  ]
}
