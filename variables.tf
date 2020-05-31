variable "name" {
  type        = string
  description = "Name used for application security group, availability set, load balancer, etc."
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region. Will default to the resource group if unspecified."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Azure tags object."
  type        = map
  default     = {}
}

variable "availability_set" {
  description = "Boolean to control creation of availability set."
  type        = bool
  default     = false // default set in local
}

variable "load_balancer" {
  description = "Boolean to control creation of basic load balancer."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Resource ID for the subnet to attach the load balancer's front-end."
  type        = string
  default     = ""
}

variable "load_balancer_rules" {
  description = "Array of load balancer rules."
  type = list(object({
    protocol      = string
    frontend_port = number
    backend_port  = number
  }))

  // Simple default added here - couldn't see this default being overridden much.
  // Set to [] if allowing load_balancer_rules_map into the default object.
  default = [{
    protocol      = "Tcp",
    frontend_port = 443,
    backend_port  = 443
    }
  ]
}

variable "module_depends_on" {
  type    = list(any)
  default = []
}

variable "defaults" {
  description = "Collection of default values."
  type = object({
    module_depends_on   = list(any)
    resource_group_name = string
    location            = string
    tags                = map(string)
    availability_set    = bool
    load_balancer       = bool
    subnet_id           = string
    /*
    load_balancer_rules_map = list(object({
      protocol      = string
      frontend_port = number
      backend_port  = number
    }))
    */
  })
  default = {
    module_depends_on   = null
    resource_group_name = null
    location            = null
    tags                = null
    availability_set    = null
    load_balancer       = null
    subnet_id           = null
  }
}
