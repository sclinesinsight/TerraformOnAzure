terraform {
    backend "azurerm" {
        resource_group_name = "shell-rg"
        storage_account_name = "terraformstatesteve"
        container_name = "terraformclass"
        key             = "tfclass.tfstate"
    }
}
