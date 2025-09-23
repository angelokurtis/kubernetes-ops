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

variable "cluster_gateway" {
  description = "Default gateway for the Kubernetes cluster"
  type        = string
}

variable "nodes" {
  description = "List of nodes (both control plane and worker)"
  type = list(object({
    name   = optional(string)
    type   = string # "control-plane" or "worker"
    cores  = optional(number)
    memory = optional(number)
    disk   = optional(number)
    ip     = optional(string)
    mac    = optional(string)
  }))

  default = [
    { type = "control-plane" },
    { type = "worker" },
    { type = "worker" },
  ]

  validation {
    condition = alltrue([
      for node in var.nodes : contains(["control-plane", "worker"], node.type)
    ])
    error_message = "Node type must be either \"control-plane\" or \"worker\"."
  }
}
