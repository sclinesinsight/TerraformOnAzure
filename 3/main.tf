terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_resource_group" {
    name = "terraform-rg"
    location = var.location
}

resource "azurerm_virtual_network" "my_vnet" {
    name = "my-vnet"
    location = azurerm_resource_group.my_resource_group.location
    resource_group_name = azurerm_resource_group.my_resource_group.name
    address_space = ["10.0.0.0/16"]
    tags = {
        environment = var.environment
    }
}