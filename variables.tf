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

variable "application_security_group" {
  description = "Boolean to control creation of application security group."
  type        = bool
  default     = false // default set in local
}

variable "load_balancer" {
  description = "Boolean to control creation of basic load balancer."
  type        = bool
  default     = null // default set in local
}

variable "defaults" {
  description = "Collection of default values."
  type        = any
  default     = {}
}

variable "module_depends_on" {
  type    = any
  default = null
}