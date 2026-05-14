variable "rg_name" {
    description = "Name of the resource group"
    type        = string
    }

variable "location" {
    description = "Location of the resource group"
    type        = string
    }

variable "tags" {
    description = "Tags to be applied to the resource group"
    type        = map(string)
    default     = {
        Environment = var.environment
        Owner       = var.owner
        Project_name= var.project_name
        Billing_level= var.billing_level
        Billing_contact= var.billing_contact
        cost_center= var.cost_center
    }
}