resource "azurecaf_name" "frontdoor_endpoint" {
  name          = var.stack
  resource_type = "azurerm_cdn_frontdoor_endpoint"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, var.use_caf_naming ? "" : "fde"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

resource "azurecaf_name" "frontdoor_profile" {
  name          = var.stack
  resource_type = "azurerm_cdn_frontdoor_profile"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, var.use_caf_naming ? "" : "fdp"])
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

resource "azurecaf_name" "frontdoor_probe" {
  name          = var.stack
  resource_type = "azurerm_frontdoor"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, "probe", var.use_caf_naming ? "" : "fd"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}

resource "azurecaf_name" "frontdoor_lb" {
  name          = var.stack
  resource_type = "azurerm_frontdoor"
  prefixes      = var.name_prefix == "" ? null : [local.name_prefix]
  suffixes      = compact([var.client_name, var.environment, local.name_suffix, "lb", var.use_caf_naming ? "" : "fd"])
  use_slug      = var.use_caf_naming
  clean_input   = true
  separator     = "-"
}
