variable "proxmox_address" {
  description = "Proxmox server address (hostname or IP, without protocol/port)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox API user, e.g. root@pam or terraform@pve"
  type        = string
}

variable "proxmox_password" {
  description = "Password for the Proxmox API user"
  type        = string
  sensitive   = true
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name            = string
    endpoint        = string
    gateway         = string
    talos_version   = string
    proxmox_cluster = string
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node     = string
    machine_type  = string
    datastore_id  = optional(string, "local-zfs")
    ip            = string
    mac_address   = string
    vm_id         = number
    cpu           = number
    ram_dedicated = number
    update        = optional(bool, false)
    igpu          = optional(bool, false)
  }))
}
