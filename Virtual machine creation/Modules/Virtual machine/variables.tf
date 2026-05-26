variable "name" {
  type        = string
  description = "Virtual machine name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the VM NIC."
}

variable "network_security_group_id" {
  type        = string
  description = "Network security group ID for the VM NIC."
}

variable "os_type" {
  type        = string
  description = "Either linux or windows."
}

variable "size" {
  type        = string
  description = "Azure VM size."
}

variable "admin_username" {
  type        = string
  description = "Local administrator username."
}

variable "admin_password" {
  type        = string
  description = "Optional Windows admin password. If omitted for Windows, one is generated."
  default     = null
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "Linux SSH public key."
  default     = null
}

variable "public_ip_enabled" {
  type        = bool
  description = "Whether to attach a public IP."
  default     = false
}

variable "private_ip_address" {
  type        = string
  description = "Optional static private IP."
  default     = null
}

variable "os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB."
  default     = 64
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Optional custom Azure marketplace image reference."
  default     = null
}

variable "data_disks" {
  type = list(object({
    name                 = string
    disk_size_gb         = number
    lun                  = number
    caching              = optional(string)
    storage_account_type = optional(string)
  }))
  description = "Optional managed data disks."
  default     = []
}

variable "custom_data" {
  type        = string
  description = "Optional cloud-init or custom data."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to VM resources."
  default     = {}
}

