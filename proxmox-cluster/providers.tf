terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.38" }
    proxmox    = { source = "bpg/proxmox", version = "~> 0.83" }
    restapi    = { source = "Mastercard/restapi", version = "~> 2.0" }
    talos      = { source = "siderolabs/talos", version = "~> 0.9" }
  }
  required_version = ">= 1.9"
}
