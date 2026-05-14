provider "azurerm" {
  features {}
}

locals {
  tags = {
    Environment     = var.environment
    Owner           = var.owner
    Project_name    = var.project_name
    Billing_level   = var.billing_level
    Billing_contact = var.billing_contact
    cost_center     = var.cost_center
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = local.tags
}