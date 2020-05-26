# terraform-azurerm-linux-vm

## Description

This Terraform module creates an availability set and then two or more VMs within it. It also associates the NICs to an application security group.

> This is a WORK IN PROGRESS and will definitely change. Support will be added for both basic load balancer creation and association with App Gateway backend pools. I may separate this from the vm modules in time. I may output an obkect that can be imported into the VM block for associations.

## Example

> CLEAN UP THE EXAMPLE TO BE A FULL STANDALONE CONFIG

```terraform
locals {
  vm_defaults = {
    module_depends_on    = ["module.hub_vnet"]
    resource_group_name  = azurerm_resource_group.rg.name
    location             = azurerm_resource_group.rg.location
    tags                 = azurerm_resource_group.rg.tags
    key_vault_id         = module.shared_services.key_vault.id
    boot_diagnostics_uri = module.shared_services.diags.uri

    admin_username       = "ubuntu"
    ssh_users            = []
    subnet_id            = module.vnet.subnets["mySubnet"].id
    vm_size              = "Standard_B1ls"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_application_security_group" "avset_example" {
  name                = "avset_example"
  resource_group_name = local.hub_vm_defaults.resource_group_name
  location            = local.hub_vm_defaults.location
  tags                = local.hub_vm_defaults.tags
}

module "avset_example" {
  source   = "../../terraform-azurerm-availability-set"
  defaults = local.hub_vm_defaults

  availability_set_name         = "avsetExample"
  names                         = ["AVS-A", "AVS-B", "AVS-C"]
  source_image_id               = data.azurerm_image.ubuntu.id
  application_security_group_id = azurerm_application_security_group.avset_example.id
}
```
