locals {
  location = var.location != "" ? var.location : lookup(var.defaults, "location", data.azurerm_resource_group.set.location)
  tags     = merge(data.azurerm_resource_group.set.tags, lookup(var.defaults, "tags", {}), var.tags)
}

data "azurerm_resource_group" "set" {
  name = coalesce(var.resource_group_name, lookup(var.defaults, "resource_group_name", "unspecified"))
}

resource "azurerm_application_security_group" "set" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.set.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_availability_set" "set" {
  for_each            = toset(var.application_security_group ? [var.name] : [])
  name                = each.value
  resource_group_name = data.azurerm_resource_group.set.name
  location            = local.location
  tags                = local.tags
}
