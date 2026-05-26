output "id" {
  value = local.os_type == "windows" ? azurerm_windows_virtual_machine.this[0].id : azurerm_linux_virtual_machine.this[0].id
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  value = var.public_ip_enabled ? azurerm_public_ip.this[0].ip_address : null
}

output "generated_admin_password" {
  value     = local.os_type == "windows" && var.admin_password == null ? random_password.admin[0].result : null
  sensitive = true
}

output "admin_password" {
  value     = local.os_type == "windows" ? (var.admin_password == null ? random_password.admin[0].result : var.admin_password) : null
  sensitive = true
}
