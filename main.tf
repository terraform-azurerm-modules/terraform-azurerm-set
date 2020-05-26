locals {
  names = length(var.names) > 0 ? var.names : list(var.name)

  module_depends_on    = coalescelist(var.module_depends_on, var.defaults.module_depends_on)
  resource_group_name  = coalesce(var.resource_group_name, var.defaults.resource_group_name)
  location             = coalesce(var.location, var.defaults.location)
  tags                 = merge(var.defaults.tags, var.tags)
  key_vault_id         = coalesce(var.key_vault_id, var.defaults.key_vault_id)
  boot_diagnostics_uri = coalesce(var.boot_diagnostics_uri, var.defaults.boot_diagnostics_uri)

  admin_username = coalesce(var.admin_username, var.defaults.admin_username)
  // ssh_users            = toset(distinct(concat([var.admin_username], coalescelist(var.ssh_users, var.defaults.ssh_users, [var.admin_username]))))
  ssh_users            = toset(distinct(concat([local.admin_username], coalescelist(var.ssh_users, var.defaults.ssh_users, [local.admin_username]))))
  subnet_id            = coalesce(var.subnet_id, var.defaults.subnet_id)
  vm_size              = coalesce(var.vm_size, var.defaults.vm_size)
  storage_account_type = coalesce(var.storage_account_type, var.defaults.storage_account_type)

}

resource "azurerm_availability_set" "avset" {
  name                = var.availability_set_name
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

module "vm" {
  source = "../terraform-azurerm-linux-vm/"
  defaults = {
    module_depends_on    = local.module_depends_on
    resource_group_name  = local.resource_group_name
    location             = local.location
    tags                 = local.tags
    key_vault_id         = local.key_vault_id
    boot_diagnostics_uri = local.boot_diagnostics_uri
    admin_username       = local.admin_username
    ssh_users            = local.ssh_users
    subnet_id            = local.subnet_id
    vm_size              = local.vm_size
    storage_account_type = local.storage_account_type
  }

  names                         = local.names
  source_image_id               = var.source_image_id
  source_image_reference        = var.source_image_reference
  availability_set_id           = azurerm_availability_set.avset.id
  application_security_group_id = var.application_security_group_id
}
