terraform {
  required_version = ">= 1.3.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.31"
    }
  }
}

provider "azurerm" {
  features {}
}
