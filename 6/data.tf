data "azurerm_key_vault" "key_vault" {
    name            = var.key_vault_name
    resource_group_name = var.key_vault_rg
}

data "azurerm_key_vault_secret" "admin_password" {
    name = "admin-password1"
    key_vault_id = data.azurerm_key_vault.key_vault.id
}