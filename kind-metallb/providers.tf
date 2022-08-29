terraform {
  required_providers {
    flux       = { source = "fluxcd/flux", version = ">= 0.16.0, < 0.17.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.6.0, < 2.7.0" }
    kind       = { source = "tehcyx/kind", version = ">= 0.0.13, < 0.1.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 1.15.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.12.1, < 2.13.0" }
  }
  required_version = ">= 1.0"
}

provider "flux" {}

provider "helm" {
  kubernetes {
    host = kind_cluster.metallb.endpoint

    client_certificate     = kind_cluster.metallb.client_certificate
    client_key             = kind_cluster.metallb.client_key
    cluster_ca_certificate = kind_cluster.metallb.cluster_ca_certificate
  }
}

provider "kind" {}

provider "kubectl" {
  host = kind_cluster.metallb.endpoint

  client_certificate     = kind_cluster.metallb.client_certificate
  client_key             = kind_cluster.metallb.client_key
  cluster_ca_certificate = kind_cluster.metallb.cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host = kind_cluster.metallb.endpoint

  client_certificate     = kind_cluster.metallb.client_certificate
  client_key             = kind_cluster.metallb.client_key
  cluster_ca_certificate = kind_cluster.metallb.cluster_ca_certificate
}
