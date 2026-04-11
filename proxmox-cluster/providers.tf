terraform {
  required_providers {
    external   = { source = "hashicorp/external", version = "~> 2.3" }
    helm       = { source = "hashicorp/helm", version = "~> 3.1" }
    http       = { source = "hashicorp/http", version = "~> 3.5" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.0" }
    local      = { source = "hashicorp/local", version = "~> 2.8" }
    null       = { source = "hashicorp/null", version = "~> 3.2" }
    proxmox    = { source = "bpg/proxmox", version = "~> 0.101" }
    talos      = { source = "siderolabs/talos", version = "~> 0.10" }
  }
  required_version = ">= 1.9"
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_address}:8006/"
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/kubeconfig"
  }
}
