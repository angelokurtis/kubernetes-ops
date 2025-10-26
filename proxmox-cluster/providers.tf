terraform {
  required_providers {
    http       = { source = "hashicorp/http", version = "~> 3.5" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.38" }
    null       = { source = "hashicorp/null", version = "~> 3.2" }
    proxmox    = { source = "bpg/proxmox", version = "~> 0.83" }
    talos      = { source = "siderolabs/talos", version = "~> 0.9" }
  }
  required_version = ">= 1.9"
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_address}:8006/"
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true
}
