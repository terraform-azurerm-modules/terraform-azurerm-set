output "name" {
  value = var.name
}

output "set_ids" {
  value = {
    application_security_group_id = azurerm_application_security_group.set.id
    availability_set_id           = try(azurerm_availability_set.set[var.name].id, null)
    load_balancer_backend_pool_id = try(azurerm_lb_backend_address_pool.set[var.name].id, null)
  }
}
