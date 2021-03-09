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

locals {
  admin_password          = data.azurerm_key_vault_secret.admin_password.value
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

resource "azurerm_subnet" "my_subnets" {
    for_each = var.solution_subnets
       name                     = each.key
       resource_group_name      = azurerm_resource_group.my_resource_group.name 
       virtual_network_name     = azurerm_virtual_network.my_vnet.name
       address_prefix           = each.value
}

resource "azurerm_public_ip" "web_server_public_ip" {
    name = "${var.resource_prefix}-public-ip"
    resource_group_name = azurerm_resource_group.my_resource_group.name 
    location = var.location
    allocation_method = var.environment == "production" ? "Static" : "Dynamic"
    domain_name_label = var.domain_name_label
}

resource "azurerm_network_interface" "web_server_nic" {
    name = "${var.resource_prefix}-${format("%02d",count.index)}-nic"
    location = azurerm_resource_group.my_resource_group.location
    resource_group_name = azurerm_resource_group.my_resource_group.name  
    count = var.web_server_count
    
    ip_configuration {
        name                            = "${var.web_server_name}-ip"
        subnet_id                       = azurerm_subnet.my_subnets["WebSubnet"].id
        private_ip_address_allocation   = "dynamic"
        public_ip_address_id = count.index == 0 ? azurerm_public_ip.web_server_public_ip.id : null
    }
}

resource "azurerm_network_security_group" "web_server_nsg" {
    name = "${var.resource_prefix}-nsg"
    location = azurerm_resource_group.my_resource_group.location
    resource_group_name = azurerm_resource_group.my_resource_group.name  
}

resource "azurerm_network_security_rule" "web_server_nsg_rule_rdp" {
    name = "RDP Inbound"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.my_resource_group.name 
    network_security_group_name = azurerm_network_security_group.web_server_nsg.name

}

resource "azurerm_subnet_network_security_group_association" "web_server_sag" {
    network_security_group_id       = azurerm_network_security_group.web_server_nsg.id
    subnet_id                       = azurerm_subnet.my_subnets["WebSubnet"].id
}

resource "azurerm_windows_virtual_machine" "web_server" {
    name = "${var.resource_prefix}-${format("%02d",count.index)}"
    location = azurerm_resource_group.my_resource_group.location
    resource_group_name = azurerm_resource_group.my_resource_group.name  
    network_interface_ids = [azurerm_network_interface.web_server_nic[count.index].id]
    availability_set_id = azurerm_availability_set.web_server_availability_set.id
    count = var.web_server_count
    size = "Standard_B1s"
    admin_username = "adminuser"
    admin_password = data.azurerm_key_vault_secret.admin_password.value

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServerSemiAnnual"
      sku       = "Datacenter-Core-1709-smalldisk"
      version   = "latest"
    }
    
}

resource "azurerm_availability_set" "web_server_availability_set" {
    name = "${var.resource_prefix}-availability-set"
    location = azurerm_resource_group.my_resource_group.location
    resource_group_name = azurerm_resource_group.my_resource_group.name  
    managed = true
    platform_fault_domain_count = 2

}