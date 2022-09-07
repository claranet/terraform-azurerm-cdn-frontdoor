terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10"
    }
    # external = {
    #   source  = "hashicorp/external"
    #   version = ">= 2"
    # }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.1, >= 1.2.19"
    }
  }
}
