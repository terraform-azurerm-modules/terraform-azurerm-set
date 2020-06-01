locals {
  resource_group_name = coalesce(var.resource_group_name, lookup(var.defaults, "resource_group_name", "unspecified"))
  location = try(coalesce(var.location, var.defaults.location), data.azurerm_resource_group.set.location)
  tags     = merge(data.azurerm_resource_group.set.tags, lookup(var.defaults, "tags", {}), var.tags)

  availability_set = var.availability_set || var.defaults.availability_set ? true : false
  load_balancer    = var.load_balancer || var.defaults.load_balancer ? true : false
  subnet_id        = var.subnet_id != "" ? var.subnet_id : lookup(var.defaults, "subnet_id", null)

  load_balancer_rules_map = {
    for rule in var.load_balancer_rules :
    join("-", [rule.protocol, rule.frontend_port, rule.backend_port]) => {
      name          = join("-", [rule.protocol, rule.frontend_port, rule.backend_port])
      protocol      = rule.protocol
      frontend_port = rule.frontend_port
      backend_port  = rule.backend_port
    }
  }
}

data "azurerm_resource_group" "set" {
  name = local.resource_group_name
}

resource "azurerm_application_security_group" "set" {
  depends_on          = [var.module_depends_on]
  name                = var.name
  resource_group_name = data.azurerm_resource_group.set.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_availability_set" "set" {
  depends_on          = [var.module_depends_on]
  for_each            = toset(local.availability_set ? [var.name] : [])
  name                = each.value
  resource_group_name = data.azurerm_resource_group.set.name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_lb" "set" {
  depends_on          = [var.module_depends_on]
  for_each            = toset(local.load_balancer ? [var.name] : [])
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
  for_each            = toset(local.load_balancer ? [var.name] : [])
  resource_group_name = data.azurerm_resource_group.set.name
  loadbalancer_id     = azurerm_lb.set[var.name].id
  name                = each.value
}

resource "azurerm_lb_probe" "set" {
  for_each            = local.load_balancer ? local.load_balancer_rules_map : {}
  name                = "probe-port-${each.value.backend_port}"
  resource_group_name = data.azurerm_resource_group.set.name
  loadbalancer_id     = azurerm_lb.set[var.name].id
  port                = each.value.backend_port // local.probe_port
}

resource "azurerm_lb_rule" "set" {
  for_each                       = local.load_balancer ? local.load_balancer_rules_map : {}
  name                           = each.value.name
  resource_group_name            = data.azurerm_resource_group.set.name
  loadbalancer_id                = azurerm_lb.set[var.name].id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "InternalIpAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.set[var.name].id
  probe_id                       = azurerm_lb_probe.set[each.value.name].id

  // Resource defaults as per https://www.terraform.io/docs/providers/azurerm/r/lb_rule.html
  enable_floating_ip      = false
  idle_timeout_in_minutes = 4
  load_distribution       = "Default" // All 5 tuples. Could  be set to  SourceIP or SourceIPProtocol.
  enable_tcp_reset        = false
  disable_outbound_snat   = false
}
