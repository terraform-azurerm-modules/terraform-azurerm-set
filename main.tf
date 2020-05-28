locals {
  location = var.location != "" ? var.location : lookup(var.defaults, "location", data.azurerm_resource_group.set.location)
  tags     = merge(data.azurerm_resource_group.set.tags, lookup(var.defaults, "tags", {}), var.tags)

  availability_set = toset(var.availability_set || lookup(var.defaults, "availability_set", false) ? [var.name] : [])
  load_balancer    = toset(var.load_balancer || lookup(var.defaults, "load_balancer", false) ? [var.name] : [])
  subnet_id        = var.subnet_id != "" ? var.subnet_id : lookup(var.defaults, "subnet_id", null)

  load_balancer_rules_default = length(local.load_balancer) > 0 ? [{ protocol = "Tcp", frontend_port = 443, backend_port = 443 }] : []
  load_balancer_rules         = length(var.load_balancer_rules) > 0 ? var.load_balancer_rules : lookup(var.defaults, "load_balancer_rules", local.load_balancer_rules_default)
  load_balancer_rules_map = {
    for rule in local.load_balancer_rules :
    join("-", [rule.protocol, rule.frontend_port, rule.backend_port]) => {
      name          = join("-", [rule.protocol, rule.frontend_port, rule.backend_port])
      protocol      = rule.protocol
      frontend_port = rule.frontend_port
      backend_port  = rule.backend_port
    }
  }
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
  for_each            = local.availability_set
  name                = each.value
  resource_group_name = data.azurerm_resource_group.set.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_lb" "set" {
  for_each            = local.load_balancer
  name                = each.value
  resource_group_name = data.azurerm_resource_group.set.name
  location            = local.location
  tags                = local.tags

  sku = "Basic"

  frontend_ip_configuration {
    name                          = "InternalIpAddress"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = local.subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "set" {
  for_each            = local.load_balancer
  resource_group_name = data.azurerm_resource_group.set.name
  loadbalancer_id     = azurerm_lb.set[var.name].id
  name                = each.value
}

resource "azurerm_lb_rule" "set" {
  for_each                       = local.load_balancer_rules_map
  resource_group_name            = data.azurerm_resource_group.set.name
  loadbalancer_id                = azurerm_lb.set[var.name].id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "InternalIpAddress"
}
