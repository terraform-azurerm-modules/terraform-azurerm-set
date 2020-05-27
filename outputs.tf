output "set" {
  value = {
    name                       = var.name
    resource_group_name        = data.azurerm_resource_group.set.name
    location                   = local.location
    tags                       = local.tags
    application_security_group = azurerm_application_security_group.set
    availability_set           = lookup(azurerm_availability_set.set, var.name, null)
  }
}
