locals {
  os_type = lower(var.os_type)
  data_disks = {
    for disk in var.data_disks : disk.name => disk
  }

  default_source_image_reference = local.os_type == "windows" ? {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
    } : {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  source_image_reference = var.source_image_reference == null ? local.default_source_image_reference : var.source_image_reference
}

resource "random_password" "admin" {
  count = local.os_type == "windows" && var.admin_password == null ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_public_ip" "this" {
  count = var.public_ip_enabled ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address == null ? "Dynamic" : "Static"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.this[0].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.os_type == "linux" ? 1 : 0

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.this.id]
  size                            = var.size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  custom_data                     = var.custom_data == null ? null : base64encode(var.custom_data)
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = local.source_image_reference.publisher
    offer     = local.source_image_reference.offer
    sku       = local.source_image_reference.sku
    version   = local.source_image_reference.version
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = local.os_type == "windows" ? 1 : 0

  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.this.id]
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password == null ? random_password.admin[0].result : var.admin_password
  custom_data           = var.custom_data == null ? null : base64encode(var.custom_data)
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = local.source_image_reference.publisher
    offer     = local.source_image_reference.offer
    sku       = local.source_image_reference.sku
    version   = local.source_image_reference.version
  }
}

resource "azurerm_managed_disk" "data" {
  for_each = local.data_disks

  name                 = "${var.name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = coalesce(each.value.storage_account_type, "Premium_LRS")
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each = local.data_disks

  managed_disk_id    = azurerm_managed_disk.data[each.key].id
  virtual_machine_id = local.os_type == "windows" ? azurerm_windows_virtual_machine.this[0].id : azurerm_linux_virtual_machine.this[0].id
  lun                = each.value.lun
  caching            = coalesce(each.value.caching, "ReadWrite")
}
