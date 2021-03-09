variable "environment" {
    type = string
}
variable "location" {
    type = string
}
variable "solution_subnets" {
    type = map
}
variable "domain_name_label" {
    type = string
}
variable "resource_prefix" {
    type = string
}
variable "key_vault_name"{
    type = string
}
variable "key_vault_rg" {
    type = string
}
variable "web_server_count" {
    type = number
}
variable "web_server_name" {
    type = string
}