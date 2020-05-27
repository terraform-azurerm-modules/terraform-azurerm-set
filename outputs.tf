output "set" {
  value = {
    name                = var.name
    resource_group_name = data.azurerm_resource_group.set.name
    location            = local.location
    tags                = local.tags
    asg_id              = azurerm_application_security_group.set.id
  }
}
