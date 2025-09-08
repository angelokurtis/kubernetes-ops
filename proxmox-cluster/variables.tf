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

variable "control_plane_count" {
  description = "Number of Kubernetes control plane nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}
