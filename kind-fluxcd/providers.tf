terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.0.12, < 0.1.0" }
    flux       = { source = "fluxcd/flux", version = ">= 0.15.1, < 0.16.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.11.0, < 2.12.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 1.15.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "flux" {}

provider "kubernetes" {
  host = kind_cluster.flux.endpoint

  client_certificate     = kind_cluster.flux.client_certificate
  client_key             = kind_cluster.flux.client_key
  cluster_ca_certificate = kind_cluster.flux.cluster_ca_certificate
}

provider "kubectl" {
  host = kind_cluster.flux.endpoint

  client_certificate     = kind_cluster.flux.client_certificate
  client_key             = kind_cluster.flux.client_key
  cluster_ca_certificate = kind_cluster.flux.cluster_ca_certificate
  load_config_file       = false
}
