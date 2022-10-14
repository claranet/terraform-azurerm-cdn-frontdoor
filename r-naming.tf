resource "azurecaf_name" "frontdoor_profile" {
  name          = var.stack
  resource_type = "azurerm_cdn_frontdoor_profile"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, var.use_caf_naming ? "" : "fdp"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

resource "azurecaf_name" "frontdoor_endpoint" {
  for_each = var.endpoints

  name          = var.stack
  resource_type = "azurerm_cdn_frontdoor_endpoint"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, each.key, var.use_caf_naming ? "" : "fde"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

resource "azurecaf_name" "frontdoor_origin_group" {
  for_each = var.origin_groups

  name          = var.stack
  resource_type = "azurerm_cdn_frontdoor_origin_group"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, each.key, var.use_caf_naming ? "" : "fdog"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

resource "azurecaf_name" "frontdoor_origin" {
  for_each = var.origins

  name          = var.stack
  resource_type = "azurerm_cdn_frontdoor_origin"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, each.key, var.use_caf_naming ? "" : "fdo"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

#TODO - Use locals instead not yet supported by CAF
resource "azurecaf_name" "frontdoor_custom_domain" {
  for_each = var.custom_domains

  name          = var.stack
  resource_type = "azurerm_custom_provider" #azurerm_cdn_frontdoor_custom_domain NOT AVAILABLE YET ?
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, each.key, var.use_caf_naming ? "" : "fdcd"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

#TODO - Use locals instead not yet supported by CAF
resource "azurecaf_name" "frontdoor_route" {
  for_each = var.routes

  name          = var.stack
  resource_type = "azurerm_custom_provider" #azurerm_cdn_frontdoor_route NOT AVAILABLE YET ?
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, each.key, var.use_caf_naming ? "" : "fdr"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}
