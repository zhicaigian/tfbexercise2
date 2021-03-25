terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azurevpc" {
  source     = "../modules/vpc"

  rgName     = var.rgName
  rgLocation = var.rgLocation

  prefix          = var.prefix
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets

  admin_username = var.admin_username
  admin_password = var.admin_password
}

output "public_ip_address" {
  value = module.azurevpc.public_ip_address
}
