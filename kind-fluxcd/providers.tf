terraform {
  required_providers {
    kind       = { source = "kyma-incubator/kind", version = ">= 0.0" }
    flux       = { source = "fluxcd/flux", version = ">= 0.11" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.8" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.13" }
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
