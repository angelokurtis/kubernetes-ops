variable "docker_volume" {
  type        = string
  description = "Docker volume for kind Image caching"
  default     = null
}

variable "load_balancer_address" {
  type        = string
  description = "The IP addresses associated with a load balancer"
  default     = "127.0.0.1"
}

variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_token" {
  type        = string
  description = "Proxmox API token"
  sensitive   = true
}

variable "proxmox_secret" {
  type        = string
  description = "Proxmox API secret"
  sensitive   = true
}
