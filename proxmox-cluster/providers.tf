terraform {
  required_providers {
    external   = { source = "hashicorp/external", version = "~> 2.3" }
    helm       = { source = "hashicorp/helm", version = "~> 3.1" }
    http       = { source = "hashicorp/http", version = "~> 3.5" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.38" }
    local      = { source = "hashicorp/local", version = "~> 2.6.1" }
    null       = { source = "hashicorp/null", version = "~> 3.2" }
    proxmox    = { source = "bpg/proxmox", version = "~> 0.87" }
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

provider "helm" {
  kubernetes = {
    host                   = yamldecode(talos_cluster_kubeconfig._.kubeconfig_raw)["clusters"][0]["cluster"]["server"]
    client_certificate     = base64decode(yamldecode(talos_cluster_kubeconfig._.kubeconfig_raw)["users"][0]["user"]["client-certificate-data"])
    client_key             = base64decode(yamldecode(talos_cluster_kubeconfig._.kubeconfig_raw)["users"][0]["user"]["client-key-data"])
    cluster_ca_certificate = base64decode(yamldecode(talos_cluster_kubeconfig._.kubeconfig_raw)["clusters"][0]["cluster"]["certificate-authority-data"])
  }
}
