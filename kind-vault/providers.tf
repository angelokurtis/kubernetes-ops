terraform {
  required_providers {
    kubectl       = { source = "alekc/kubectl", version = "~> 2.4" }
    kubernetes    = { source = "hashicorp/kubernetes", version = "~> 3.2" }
    kustomization = { source = "kbst/kustomization", version = "~> 0.9" }
    null          = { source = "hashicorp/null", version = "~> 3.3" }
    vault         = { source = "hashicorp/vault", version = "~> 5.10" }
    external      = { source = "hashicorp/external", version = "~> 2.4" }
    helm          = { source = "hashicorp/helm", version = "~> 3.2" }
    kind          = { source = "tehcyx/kind", version = "~> 0.11" }
  }
  required_version = ">= 1.9"
}

provider "kubectl" {
  host = kind_cluster.vault.endpoint

  client_certificate     = kind_cluster.vault.client_certificate
  client_key             = kind_cluster.vault.client_key
  cluster_ca_certificate = kind_cluster.vault.cluster_ca_certificate
  load_config_file       = false
  lazy_load              = true
}

provider "kubernetes" {
  host = kind_cluster.vault.endpoint

  client_certificate     = kind_cluster.vault.client_certificate
  client_key             = kind_cluster.vault.client_key
  cluster_ca_certificate = kind_cluster.vault.cluster_ca_certificate
}

provider "kustomization" {
  kubeconfig_raw = kind_cluster.vault.kubeconfig
}

provider "null" {
}

provider "vault" {
  address = "http://vault.${local.cluster_host}/"
  token   = "root"
}

provider "helm" {
  kubernetes = {
    host = kind_cluster.vault.endpoint

    client_certificate     = kind_cluster.vault.client_certificate
    client_key             = kind_cluster.vault.client_key
    cluster_ca_certificate = kind_cluster.vault.cluster_ca_certificate
  }
}

provider "kind" {}
